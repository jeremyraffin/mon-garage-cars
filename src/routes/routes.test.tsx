import { render, screen } from '@testing-library/react';
import { createMemoryRouter, RouterProvider } from 'react-router';
import { describe, expect, it } from 'vitest';
import { routes } from '../router';

function renderAt(path: string) {
  const router = createMemoryRouter(routes, { initialEntries: [path] });
  render(<RouterProvider router={router} />);
}

describe('app shell routes', () => {
  it('renders the Vitrine at /', () => {
    renderAt('/');
    expect(
      screen.getByRole('heading', { name: 'Mon Garage de Miniatures' }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole('link', { name: 'Aller au Garage' }),
    ).toHaveAttribute('href', '/garage');
  });

  it('renders the Garage shell at /garage', () => {
    renderAt('/garage');
    expect(screen.getByRole('heading', { name: 'Garage' })).toBeInTheDocument();
  });
});
