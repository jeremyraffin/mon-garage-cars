import type { CSSProperties } from 'react';
import styles from './ShowcaseCard.module.css';
import type { ShowcaseFiche } from './showcaseFiches';

type ShowcaseCardProps = {
  fiche: ShowcaseFiche;
  eager?: boolean;
};

export function ShowcaseCard({ fiche, eager = false }: ShowcaseCardProps) {
  return (
    <li
      className={styles.card}
      style={{ '--fiche-accent': fiche.accent } as CSSProperties}
    >
      <img
        className={styles.photo}
        src={fiche.photo}
        alt={fiche.photoAlt}
        width={720}
        height={540}
        loading={eager ? 'eager' : 'lazy'}
        decoding="async"
      />
      <div className={styles.band} aria-hidden="true" />
      <div className={styles.text}>
        {fiche.number ? (
          <span className={styles.number}>
            <span className={styles.srOnly}>Numéro </span>
            {fiche.number}
          </span>
        ) : null}
        <span className={styles.name}>{fiche.name}</span>
      </div>
      {fiche.isNew ? <span className={styles.badge}>Nouveau</span> : null}
    </li>
  );
}
