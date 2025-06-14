import Link from 'next/link';

const Header = () => {
  return (
    <header className="bg-white shadow-md w-full z-10 flex-shrink-0">
      <nav className="container mx-auto px-6 py-4 flex justify-between items-center">
        <Link href="/" className="text-xl font-bold text-gray-800 hover:text-gray-700">
          Academic Journal Club Locator
        </Link>
        <div>
          {/* In a future step, we will replace this with dynamic auth state */}
          <button className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-colors duration-300">
            Sign In with GitHub
          </button>
        </div>
      </nav>
    </header>
  );
};

export default Header;
