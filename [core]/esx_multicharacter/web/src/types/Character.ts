export interface Character {
  id: string;
  name: string;
  birthDate: string;
  gender: 'MALE' | 'FEMALE';
  occupation: string;
  isActive?: boolean;
  disabled?: boolean;
}

export interface Locale {
  char_info_title: string;
  play : string;
  title : string;
}