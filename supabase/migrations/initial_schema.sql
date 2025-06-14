/*
  # Initial Schema Setup (Corrected)

  This migration sets up the initial database schema for the Academic Journal Club Locator.
  It has been corrected to handle partial migrations by ensuring the `is_admin` column is added idempotently.

  1.  **New Tables**
      - `profiles`: Stores user profile information, linked to `auth.users`. Includes an `is_admin` flag.
      - `journal_clubs`: Stores information about each journal club, including location and meeting details.

  2.  **Functions & Triggers**
      - `handle_new_user()`: A function that runs when a new user signs up. It creates a corresponding profile entry and makes the first user an admin.
      - A trigger on `auth.users` that calls `handle_new_user` after each new user insertion.

  3.  **Security**
      - Row Level Security (RLS) is enabled on both `profiles` and `journal_clubs`.
      - **Policies for `profiles`**:
        - Users can view all profiles.
        - Users can only insert and update their own profile.
      - **Policies for `journal_clubs`**:
        - Anyone can view all journal clubs.
        - Authenticated users can create journal clubs.
        - Users can only update or delete the journal clubs they created.
*/

-- 1. Profiles Table
-- Create the table if it doesn't exist.
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  updated_at timestamptz,
  username text UNIQUE,
  full_name text,
  avatar_url text
);

-- Add the is_admin column idempotently to avoid errors on re-runs.
-- This handles the case where the table exists but the column is missing.
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin boolean DEFAULT false NOT NULL;


COMMENT ON TABLE public.profiles IS 'Profile information for users.';
COMMENT ON COLUMN public.profiles.is_admin IS 'Flag to indicate if a user is an administrator.';

-- 2. Journal Clubs Table
CREATE TABLE IF NOT EXISTS public.journal_clubs (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  created_at timestamptz DEFAULT now() NOT NULL,
  name text NOT NULL,
  description text,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  meeting_details text,
  created_by uuid REFERENCES public.profiles(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.journal_clubs IS 'Stores data for each journal club.';

-- 3. Set up Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_clubs ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for Profiles
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone."
  ON public.profiles FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile." ON public.profiles;
CREATE POLICY "Users can insert their own profile."
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile." ON public.profiles;
CREATE POLICY "Users can update their own profile."
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 5. RLS Policies for Journal Clubs
DROP POLICY IF EXISTS "Journal clubs are viewable by everyone." ON public.journal_clubs;
CREATE POLICY "Journal clubs are viewable by everyone."
  ON public.journal_clubs FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can create journal clubs." ON public.journal_clubs;
CREATE POLICY "Authenticated users can create journal clubs."
  ON public.journal_clubs FOR INSERT
  TO authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS "Users can update their own journal clubs." ON public.journal_clubs;
CREATE POLICY "Users can update their own journal clubs."
  ON public.journal_clubs FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

DROP POLICY IF EXISTS "Users can delete their own journal clubs." ON public.journal_clubs;
CREATE POLICY "Users can delete their own journal clubs."
  ON public.journal_clubs FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);


-- 6. Function to handle new user sign-ups and set first user as admin
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  admin_exists boolean;
BEGIN
  -- Check if an admin already exists
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE is_admin = true) INTO admin_exists;

  -- Insert a new profile for the new user
  -- If no admin exists, make this user the admin
  INSERT INTO public.profiles (id, username, avatar_url, is_admin)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'user_name', -- For GitHub provider
    new.raw_user_meta_data->>'avatar_url',
    NOT admin_exists
  );
  RETURN new;
END;
$$;

-- 7. Trigger to call the function on new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
