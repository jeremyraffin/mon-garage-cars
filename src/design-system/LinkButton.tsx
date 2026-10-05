import type { ReactNode } from 'react';
import { Link } from 'react-router';
import styles from './LinkButton.module.css';

type LinkButtonProps = {
  to: string;
  children: ReactNode;
};

export function LinkButton({ to, children }: LinkButtonProps) {
  return (
    <Link className={styles.button} to={to}>
      {children}
    </Link>
  );
}
