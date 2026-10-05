import { LinkButton } from '../design-system/LinkButton';
import { Page } from '../design-system/Page';
import { Checkerboard } from '../vitrine/Checkerboard';
import { ShowcaseCard } from '../vitrine/ShowcaseCard';
import { showcaseFiches } from '../vitrine/showcaseFiches';
import styles from './VitrinePage.module.css';

const EAGER_PHOTOS = 4;

export function VitrinePage() {
  return (
    <>
      <Checkerboard />
      <Page title="Mon Garage de Miniatures" variant="showcase">
        <p className={styles.intro}>
          Entrez dans le garage ! Des pilotes de la Piston Cup aux habitants de
          Radiator Springs, voici une sélection de ma collection de miniatures{' '}
          <em>Cars</em>, voiture par voiture.
        </p>
        <p className={styles.notice}>
          Projet personnel, non commercial et sans affiliation avec
          Disney/Pixar.
        </p>
        <ul className={styles.grid} aria-label="Fiches de la Vitrine">
          {showcaseFiches.map((fiche, index) => (
            <ShowcaseCard
              key={fiche.id}
              fiche={fiche}
              eager={index < EAGER_PHOTOS}
            />
          ))}
        </ul>
        <div className={styles.cta}>
          <LinkButton to="/garage">Aller au Garage</LinkButton>
        </div>
      </Page>
    </>
  );
}
