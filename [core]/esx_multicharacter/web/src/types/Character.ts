/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

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
  action_failed?: string;
  action_pending?: string;
}
