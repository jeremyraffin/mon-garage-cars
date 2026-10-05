import type { ReactNode } from 'react';
import styles from './Page.module.css';

type PageProps = {
  title: string;
  variant?: 'narrow' | 'showcase';
  children: ReactNode;
};

export function Page({ title, variant = 'narrow', children }: PageProps) {
  const showcase = variant === 'showcase';
  return (
    <main className={showcase ? `${styles.page} ${styles.wide}` : styles.page}>
      <h1
        className={
          showcase ? `${styles.title} ${styles.display}` : styles.title
        }
      >
        {title}
      </h1>
      {children}
    </main>
  );
}
