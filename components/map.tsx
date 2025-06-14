'use client';

import L, { LatLngExpression } from 'leaflet';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';

// This is a classic workaround for a common issue with Leaflet and bundlers like Webpack.
// It manually resets the paths for the default marker icons.
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png';
import iconUrl from 'leaflet/dist/images/marker-icon.png';
import shadowUrl from 'leaflet/dist/images/marker-shadow.png';

// The 'delete' is a bit of a hack, but it's a well-known fix for this specific problem.
// It prevents Leaflet from trying to guess the icon path, which often fails in a bundled environment.
if (typeof window !== 'undefined') {
  delete (L.Icon.Default.prototype as any)._getIconUrl;

  L.Icon.Default.mergeOptions({
    iconRetinaUrl: iconRetinaUrl.src,
    iconUrl: iconUrl.src,
    shadowUrl: shadowUrl.src,
  });
}


const Map = () => {
  // Default position (central Europe) and a wider zoom to see more of the world.
  const position: LatLngExpression = [48.8566, 2.3522]; 

  // Dummy data for journal clubs to demonstrate functionality.
  // In a future step, we will fetch this data from our Supabase database.
  const journalClubs = [
    { id: 1, name: 'Neuroscience Journal Club @ UCL', position: [51.5246, -0.134] as LatLngExpression, description: 'Weekly discussions on cutting-edge neuroscience papers.' },
    { id: 2, name: 'MIT Comp-Bio Club', position: [42.3601, -71.0942] as LatLngExpression, description: 'Exploring computational biology and bioinformatics.' },
    { id: 3, name: 'Stanford AI Ethics Group', position: [37.4275, -122.1697] as LatLngExpression, description: 'Debating the societal impact of artificial intelligence.' },
    { id: 4, name: 'Charité Medical Physics Colloquium', position: [52.5244, 13.4105] as LatLngExpression, description: 'Covering new research in medical imaging and therapy.' },
    { id: 5, name: 'RIKEN BDR Seminar', position: [34.6784, 135.5209] as LatLngExpression, description: 'Frontiers in developmental biology and regeneration.' },
  ];

  return (
    <MapContainer center={position} zoom={3} scrollWheelZoom={true} className="w-full h-full">
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
        url="https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png"
      />
      {journalClubs.map(club => (
        <Marker key={club.id} position={club.position}>
          <Popup>
            <div className="p-1">
              <h3 className="font-bold text-lg mb-1">{club.name}</h3>
              <p className="text-gray-600">{club.description}</p>
            </div>
          </Popup>
        </Marker>
      ))}
    </MapContainer>
  );
};

export default Map;
