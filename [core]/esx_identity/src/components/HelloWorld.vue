<script setup>
import { ref } from 'vue'
import { Form, Field, ErrorMessage } from 'vee-validate';
import * as yup from 'yup'
import moment from 'moment'

const onSubmit = (values) => {
    fetch("http://esx_identity/register", {
            method: "POST",
            body: JSON.stringify({
                firstname: values.firstname,
                lastname: values.lastname,
                dateofbirth: values.dob,
                sex: values.gender,
                height: values.height,
            }),
        });
}

const schema = yup.object({
    firstname: yup.string().required('Firstname is required').min(3, 'Firstname must be at least 3 characters'),
    lastname: yup.string().required('Lastname is required').min(3, 'Lastname must be at least 3 characters'),
    dob: yup.date().required('Date of Birth is required').transform((value, originalValue) => {
        const parsedDate = moment(originalValue, 'DD/MM/YYYY', true);
        return parsedDate.isValid() ? parsedDate.toDate() : new Date('');
    }).typeError('Date must be in mm/dd/yyyy format'),
    gender: yup.string().required('Gender is required'),
    height: yup.number().required('Height is required').min(120, 'Minimum height is 120cm').max(220, 'Maximum height is 220cm').typeError('Amount must be a number'),
})

</script>

<template>
    <div class="dialog">
        <div class="dialog__header">
            <h1>CHARACTER <span>IDENTITY</span></h1>
        </div>
        <div class="dialog__body">
            <p class="dialog__body-hint">Start by creating your identity</p>
            <Form class="dialog__body-form" id="register" action="#" novalidate @submit="onSubmit" :validation-schema="schema">
                <div class="dialog__form-group">
                    <label for="firstname">Firstname</label>
                    <div class="dialog__form-validation">
                        <Field id="firstname" type="text" name="firstname" placeholder="Firstname" validateOnInput />
                        <!-- <i class="fas fa-check-circle" style="color: #478444;"></i> -->
                    </div>
                    <ErrorMessage name="firstname" class="dialog__form-message dialog__form-message--error" />
                </div>
                <div class="dialog__form-group">
                    <label for="lastname">Lastname</label>
                    <div class="dialog__form-validation">
                        <Field id="lastname" type="text" name="lastname" placeholder="Lastname" validateOnInput />
                        <!-- <i class="fas fa-times-circle" style="color: #733838;"></i> -->
                    </div>
                    <ErrorMessage name="lastname" class="dialog__form-message dialog__form-message--error" />
                </div>
                <div class="dialog__form-group">
                    <label for="dob">Date of birth</label>
                    <Field id="dob" type="text" name="dob" placeholder="mm/dd/yyyy" validateOnInput />
                    <ErrorMessage name="dob" class="dialog__form-message dialog__form-message--error" />
                </div>
                <div class="dialog__form-group">
                    <label for="gender">Gender</label>
                    <div class="dialog__form-group dialog__form-group--radio">
                        <div class="dialog__form-radio">
                            <Field type="radio" id="male" value="m" name="gender" validateOnInput />
                            <label for="male">
                                <i class="fas fa-mars"></i>Male
                            </label>
                        </div>
                        <div class="dialog__form-radio">
                            <Field type="radio" id="female" value="f" name="gender" validateOnInput />
                            <label for="female">
                                <i class="fas fa-venus"></i>Female
                            </label>
                        </div>
                    </div>
                    <ErrorMessage name="gender" class="dialog__form-message dialog__form-message--error" />
                </div>
                <div class="dialog__form-group">
                    <label for="height">Height</label>
                    <Field id="height" type="text" name="height" placeholder="175" validateOnInput/>
                    <ErrorMessage name="height" class="dialog__form-message dialog__form-message--error" />
                </div>
                <button class="dialog__form-submit" id="submit" type="submit">
                    <i class="fas fa-user-plus"></i>CREATE
                </button>
            </Form>
        </div>
    </div>
</template>

<style scoped>
</style>
