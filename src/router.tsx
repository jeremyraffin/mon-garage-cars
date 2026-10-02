import { createBrowserRouter } from 'react-router';
import { GaragePage } from './routes/GaragePage';
import { ShowcasePage } from './routes/ShowcasePage';

export const routes = [
  { path: '/', element: <ShowcasePage /> },
  { path: '/garage', element: <GaragePage /> },
];

export const router = createBrowserRouter(routes);
