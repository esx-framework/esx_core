// SPDX-License-Identifier: GPL-3.0-only
import { createTranslator } from "./i18n.js";

export const defaults = { maxNameLength: 20, minHeight: 120, maxHeight: 220, maxAge: 100, currentYear: new Date().getFullYear(), locale: "en", dateFormat: "DD/MM/YYYY" };

export function dateLabel(value, dateFormat = defaults.dateFormat) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value || "")) return "";
    const [year, month, day] = value.split("-");
    if (dateFormat === "MM/DD/YYYY") return `${month}/${day}/${year}`;
    if (dateFormat === "YYYY/MM/DD") return `${year}/${month}/${day}`;
    return `${day}/${month}/${year}`;
}

export function validateIdentity(form, settings = defaults, translate = createTranslator(settings.locale)) {
    const errors = {};
    for (const key of ["firstname", "lastname"]) {
        const name = form[key].trim();
        if (!name) errors[key] = key === "firstname" ? translate("firstnameRequired") : translate("lastnameRequired");
        else if (new TextEncoder().encode(name).length >= settings.maxNameLength) errors[key] = translate("nameTooLong");
        else if (!/^[\p{L} -]+$/u.test(name)) errors[key] = translate("nameCharacters");
    }
    const [year, month, day] = (form.dob || "").split("-").map(Number);
    const date = new Date(year, month - 1, day);
    if (!/^\d{4}-\d{2}-\d{2}$/.test(form.dob || "") || date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) errors.dob = translate("invalidDob");
    else if (year < settings.currentYear - settings.maxAge || year > settings.currentYear - 18) {
        // ESX validates the birth year, rather than the exact birthday.
        errors.dob = translate("dobYearRange", { minYear: settings.currentYear - settings.maxAge, maxYear: settings.currentYear - 18 });
    }
    if (!["m", "f"].includes(form.gender)) errors.gender = translate("genderRequired");
    const height = Number(form.height);
    if (!Number.isFinite(height) || height < settings.minHeight || height > settings.maxHeight) errors.height = translate("heightRange", { minHeight: settings.minHeight, maxHeight: settings.maxHeight });
    return errors;
}

export function toPayload(form) {
    return { firstname: form.firstname.trim(), lastname: form.lastname.trim(), dateofbirth: dateLabel(form.dob), sex: form.gender, height: Number(form.height) };
}
