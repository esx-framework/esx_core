<!-- SPDX-License-Identifier: GPL-3.0-only -->
<script setup>
import { computed, nextTick, onMounted, reactive, ref, watch } from "vue";
import { defaults, validateIdentity, toPayload } from "../identity.js";
import { createTranslator, normalizeLocale } from "../i18n.js";
import { isPreview, postNui } from "../nui.js";

const props = defineProps({ settings: { type: Object, default: () => ({}) }, theme: { type: Object, default: () => ({}) } });
const settings = computed(() => ({ ...defaults, ...props.settings }));
const activeLocale = computed(() => normalizeLocale(settings.value.locale));
const t = computed(() => createTranslator(activeLocale.value));
const form = reactive({ firstname: "", lastname: "", dob: "", gender: "", height: 175 });
const touched = reactive({});
const attempted = ref(false);
const pending = ref(false);
const feedback = ref("");
const previewComplete = ref(false);
const firstInput = ref(null);
const logoFailed = ref(false);
const customLogo = computed(() => (typeof props.theme?.logoUrl === "string" ? props.theme.logoUrl.trim() : ""));
watch(customLogo, () => (logoFailed.value = false));
const errors = computed(() => validateIdentity(form, settings.value, t.value));
const completed = computed(() => Object.keys(form).filter((key) => !errors.value[key]).length);
const minDate = computed(() => `${settings.value.currentYear - settings.value.maxAge}-01-01`);
const maxDate = computed(() => `${settings.value.currentYear - 18}-12-31`);
const errorFor = (key) => (attempted.value || touched[key] ? errors.value[key] : "");
const serverMessage = (message) => {
    if (!message) return t.value("registerFailed");
    const translated = t.value(message);
    return translated === message ? message : translated;
};

onMounted(() => firstInput.value?.focus());

async function submit() {
    if (pending.value || previewComplete.value) return;
    attempted.value = true;
    feedback.value = "";
    if (Object.keys(errors.value).length) {
        await nextTick();
        document.querySelector('[aria-invalid="true"]')?.focus();
        return;
    }
    pending.value = true;
    try {
        const result = await postNui("register", toPayload(form));
        if (!result?.ok) throw new Error(serverMessage(result?.error));
        if (isPreview) {
            previewComplete.value = true;
            feedback.value = t.value("previewCompleteFeedback");
        }
    } catch (error) {
        feedback.value = error.name === "AbortError" ? t.value("serverSlow") : error.message || t.value("connectionFailed");
    } finally {
        pending.value = false;
    }
}
</script>

<template>
    <main class="identity-stage" :class="{ 'is-preview': isPreview }" :lang="activeLocale">
        <div class="brand-lockup brand-header">
            <img v-if="customLogo && !logoFailed" :src="customLogo" alt="ESX" class="brand-logo" @error="logoFailed = true" />
            <img v-else src="/brand-logo.png" alt="ESX" class="brand-logo" />
            <span class="brand-divider"></span>
            <span class="eyebrow">{{ t("roleplay") }}<br /><b>{{ t("newLife") }}</b></span>
        </div>
        <section class="identity-shell">
            <div class="form-panel">
                <div class="form-heading">
                    <h2>{{ t("formTitle") }}</h2>
                    <p>{{ t("formSubtitle") }}</p>
                </div>
                <form novalidate @submit.prevent="submit" :aria-label="t('formAria')" :aria-busy="pending">
                    <fieldset :disabled="pending || previewComplete" class="form-fields">
                        <legend class="sr-only">{{ t("fieldsetLegend") }}</legend>
                        <div class="field-row">
                            <div class="field">
                                <label for="firstname"
                                    >{{ t("firstname") }} <span>{{ t("required") }}</span></label
                                ><input
                                    ref="firstInput"
                                    id="firstname"
                                    v-model="form.firstname"
                                    type="text"
                                    :placeholder="t('firstnamePlaceholder')"
                                    autocomplete="off"
                                    :maxlength="settings.maxNameLength - 1"
                                    :aria-invalid="!!errorFor('firstname')"
                                    aria-describedby="firstname-error"
                                    @blur="touched.firstname = true"
                                /><span id="firstname-error" class="field-error">{{ errorFor("firstname") }}</span>
                            </div>
                            <div class="field">
                                <label for="lastname"
                                    >{{ t("lastname") }} <span>{{ t("required") }}</span></label
                                ><input
                                    id="lastname"
                                    v-model="form.lastname"
                                    type="text"
                                    :placeholder="t('lastnamePlaceholder')"
                                    autocomplete="off"
                                    :maxlength="settings.maxNameLength - 1"
                                    :aria-invalid="!!errorFor('lastname')"
                                    aria-describedby="lastname-error"
                                    @blur="touched.lastname = true"
                                /><span id="lastname-error" class="field-error">{{ errorFor("lastname") }}</span>
                            </div>
                        </div>
                        <div class="field">
                            <label for="dob"
                                >{{ t("dob") }} <span>{{ t("required") }}</span
                                ><span class="label-meta">{{ t("ageHint", { maxAge: settings.maxAge }) }}</span></label
                            ><input id="dob" v-model="form.dob" type="date" :min="minDate" :max="maxDate" :aria-invalid="!!errorFor('dob')" aria-describedby="dob-error" @blur="touched.dob = true" /><span id="dob-error" class="field-error">{{ errorFor("dob") }}</span>
                        </div>
                        <fieldset class="gender-field">
                            <legend>
                                {{ t("gender") }} <span>{{ t("required") }}</span>
                            </legend>
                            <div class="gender-options">
                                <label class="gender-option" :class="{ selected: form.gender === 'm' }"
                                    ><input v-model="form.gender" type="radio" name="gender" value="m" :aria-invalid="!!errorFor('gender')" aria-describedby="gender-error" /><svg viewBox="0 0 24 24" aria-hidden="true">
                                        <circle cx="10" cy="14" r="6" />
                                        <path d="m14.5 9.5 6-6M15 3h6v6" /></svg
                                    ><span>{{ t("male") }}</span
                                    ><span class="radio-dot"></span></label
                                ><label class="gender-option" :class="{ selected: form.gender === 'f' }"
                                    ><input v-model="form.gender" type="radio" name="gender" value="f" :aria-invalid="!!errorFor('gender')" aria-describedby="gender-error" /><svg viewBox="0 0 24 24" aria-hidden="true">
                                        <circle cx="12" cy="8" r="6" />
                                        <path d="M12 14v8m-4-4h8" /></svg
                                    ><span>{{ t("female") }}</span
                                    ><span class="radio-dot"></span
                                ></label>
                            </div>
                            <span id="gender-error" class="field-error">{{ errorFor("gender") }}</span>
                        </fieldset>
                        <div class="field height-field">
                            <label for="height"
                                >{{ t("height") }} <span>{{ t("required") }}</span
                                ><span class="label-meta">{{ t("heightMeta", { minHeight: settings.minHeight, maxHeight: settings.maxHeight }) }}</span></label
                            >
                            <div class="height-controls">
                                <input
                                    class="height-slider"
                                    type="range"
                                    v-model.number="form.height"
                                    :min="settings.minHeight"
                                    :max="settings.maxHeight"
                                    step="1"
                                    :aria-label="t('adjustHeight')"
                                    :style="{ '--range-progress': `${Math.min(100, Math.max(0, ((form.height - settings.minHeight) / (settings.maxHeight - settings.minHeight)) * 100))}%` }"
                                />
                                <div class="height-value">
                                    <input id="height" v-model="form.height" type="number" :min="settings.minHeight" :max="settings.maxHeight" step="1" :aria-invalid="!!errorFor('height')" aria-describedby="height-error" @blur="touched.height = true" /><span>{{ t("centimeters") }}</span>
                                </div>
                            </div>
                            <span id="height-error" class="field-error">{{ errorFor("height") }}</span>
                        </div>
                    </fieldset>
                    <p v-if="feedback" class="submit-feedback" :class="{ success: previewComplete }" role="status">{{ feedback }}</p>
                    <button id="submit" class="submit-button" type="submit" :disabled="pending || previewComplete">
                        <span>{{ pending ? t("registering") : previewComplete ? t("previewDone") : t("submit") }}</span
                        ><span v-if="pending" class="spinner" aria-hidden="true"></span><svg v-else viewBox="0 0 24 24" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6" /></svg>
                    </button>
                    <div class="form-bottomline">
                        <span>{{ t("completed", { completed }) }}</span
                        ><span class="keyboard-hint"><kbd>↵</kbd> {{ t("continueHint") }}</span>
                    </div>
                </form>
            </div>
        </section>
        <div v-if="isPreview" class="preview-badge">{{ t("previewBadge") }}</div>
    </main>
</template>
