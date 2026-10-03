import { createBrowserRouter } from 'react-router';
import { GaragePage } from './routes/GaragePage';
import { VitrinePage } from './routes/VitrinePage';

export const routes = [
  { path: '/', element: <VitrinePage /> },
  { path: '/garage', element: <GaragePage /> },
];

export const router = createBrowserRouter(routes);
