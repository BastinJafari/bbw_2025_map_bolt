import './globals.css';
import 'leaflet/dist/leaflet.css';
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import Header from '@/components/header';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Academic Journal Club Locator',
  description: 'Find and share academic journal clubs around the world.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={`${inter.className} flex flex-col h-screen bg-gray-50`}>
        <Header />
        <main className="flex-grow">{children}</main>
      </body>
    </html>
  );
}
