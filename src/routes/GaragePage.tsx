import { Link } from 'react-router';
import { Page } from '../design-system/Page';

export function GaragePage() {
  return (
    <Page title="Garage">
      <p>Coquille technique neutre du Garage.</p>
      <Link to="/">Retour à la Vitrine</Link>
    </Page>
  );
}
