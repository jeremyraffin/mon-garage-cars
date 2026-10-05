import { render, screen, within } from '@testing-library/react';
import { createMemoryRouter, RouterProvider } from 'react-router';
import { describe, expect, it } from 'vitest';
import { routes } from '../router';

function renderVitrine() {
  const router = createMemoryRouter(routes, { initialEntries: ['/'] });
  render(<RouterProvider router={router} />);
}

const approvedNames = [
  'Flash McQueen',
  'Cruz Ramirez',
  'Jackson Storm',
  'Sterling',
  'Chick Hicks',
  'Luigi',
  'Guido',
  'Spikey Fillups',
];

describe('Vitrine page', () => {
  it('shows the title, the presentation and the non-affiliation notice', () => {
    renderVitrine();
    expect(
      screen.getByRole('heading', {
        level: 1,
        name: 'Mon Garage de Miniatures',
      }),
    ).toBeInTheDocument();
    expect(
      screen.getByText(
        'Projet personnel, non commercial et sans affiliation avec Disney/Pixar.',
      ),
    ).toBeInTheDocument();
    expect(
      screen.getByText(/petite collection de miniatures/),
    ).toBeInTheDocument();
  });

  it('lists exactly the eight approved Fiches, in order', () => {
    renderVitrine();
    const items = within(
      screen.getByRole('list', { name: 'Fiches de la Vitrine' }),
    ).getAllByRole('listitem');
    expect(items).toHaveLength(8);
    approvedNames.forEach((name, index) => {
      expect(items[index]).toHaveTextContent(name);
    });
  });

  it('gives each card a photo with alternative text and lazy loading past the first screen', () => {
    renderVitrine();
    const images = screen.getAllByRole('img');
    expect(images).toHaveLength(8);
    images.forEach((image, index) => {
      expect(image).toHaveAttribute('alt', expect.stringMatching(/\S/));
      expect(image).toHaveAttribute('loading', index < 4 ? 'eager' : 'lazy');
    });
    expect(
      screen.getByRole('img', { name: 'Photo de la miniature de Luigi' }),
    ).toBeInTheDocument();
  });

  it('exposes the number as text only when it exists', () => {
    renderVitrine();
    const [mcqueen, , , sterling] = screen.getAllByRole('listitem');
    expect(mcqueen).toHaveTextContent('Numéro 95');
    expect(sterling).not.toHaveTextContent('Numéro');
  });

  it('shows the Nouveau badge only on Chick Hicks, Luigi and Guido', () => {
    renderVitrine();
    const flagged = screen
      .getAllByRole('listitem')
      .filter((item) => within(item).queryByText('Nouveau'));
    expect(flagged.map((item) => item.textContent)).toEqual([
      expect.stringContaining('Chick Hicks'),
      expect.stringContaining('Luigi'),
      expect.stringContaining('Guido'),
    ]);
  });

  it('keeps cards purely presentational', () => {
    renderVitrine();
    const list = screen.getByRole('list', { name: 'Fiches de la Vitrine' });
    expect(within(list).queryByRole('button')).toBeNull();
    expect(within(list).queryByRole('link')).toBeNull();
  });

  it('offers a single CTA to /garage', () => {
    renderVitrine();
    expect(screen.getAllByRole('link')).toHaveLength(1);
    expect(
      screen.getByRole('link', { name: 'Aller au Garage' }),
    ).toHaveAttribute('href', '/garage');
  });
});
