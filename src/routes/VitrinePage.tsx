import { Link } from 'react-router';
import { Page } from '../design-system/Page';

export function VitrinePage() {
  return (
    <Page title="Mon Garage de Miniatures">
      <p>Coquille technique neutre de la Vitrine.</p>
      <Link to="/garage">Aller au Garage</Link>
    </Page>
  );
}
