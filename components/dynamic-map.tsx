import dynamic from 'next/dynamic';

const Map = dynamic(() => import('@/components/map'), {
  ssr: false,
  loading: () => <div className="flex items-center justify-center w-full h-full bg-gray-200"><p>Loading map...</p></div>,
});

export default Map;
