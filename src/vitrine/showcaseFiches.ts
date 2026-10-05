import chick from './photos/chick.jpg';
import cruz from './photos/cruz.jpg';
import guido from './photos/guido.jpg';
import luigi from './photos/luigi.jpg';
import mcqueen from './photos/mcqueen.jpg';
import spikey from './photos/spikey.jpg';
import sterling from './photos/sterling.jpg';
import storm from './photos/storm.jpg';

export type ShowcaseFiche = {
  id: string;
  name: string;
  number?: string;
  accent: string;
  isNew: boolean;
  photo: string;
  photoAlt: string;
};

// Static, publicly approved selection (issue #3). Never derived from the Garage.
export const showcaseFiches: readonly ShowcaseFiche[] = [
  {
    id: 'mcqueen',
    name: 'Flash McQueen',
    number: '95',
    accent: '#e5322b',
    isNew: false,
    photo: mcqueen,
    photoAlt: 'Photo de la miniature de Flash McQueen',
  },
  {
    id: 'cruz',
    name: 'Cruz Ramirez',
    number: '95',
    accent: '#e8c31a',
    isNew: false,
    photo: cruz,
    photoAlt: 'Photo de la miniature de Cruz Ramirez',
  },
  {
    id: 'storm',
    name: 'Jackson Storm',
    number: '2.0',
    accent: '#495057',
    isNew: false,
    photo: storm,
    photoAlt: 'Photo de la miniature de Jackson Storm',
  },
  {
    id: 'sterling',
    name: 'Sterling',
    accent: '#adb5bd',
    isNew: false,
    photo: sterling,
    photoAlt: 'Photo de la miniature de Sterling',
  },
  {
    id: 'chick',
    name: 'Chick Hicks',
    number: '86',
    accent: '#2f9e44',
    isNew: true,
    photo: chick,
    photoAlt: 'Photo de la miniature de Chick Hicks',
  },
  {
    id: 'luigi',
    name: 'Luigi',
    accent: '#e8c31a',
    isNew: true,
    photo: luigi,
    photoAlt: 'Photo de la miniature de Luigi',
  },
  {
    id: 'guido',
    name: 'Guido',
    accent: '#1c7ed6',
    isNew: true,
    photo: guido,
    photoAlt: 'Photo de la miniature de Guido',
  },
  {
    id: 'spikey',
    name: 'Spikey Fillups',
    number: '5',
    accent: '#2f9e44',
    isNew: false,
    photo: spikey,
    photoAlt: 'Photo de la miniature de Spikey Fillups',
  },
];
