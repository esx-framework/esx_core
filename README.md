# fxserver-esx_joblisting
FR - Pôle Emploi

Update SQL database for job whitelist:

ALTER TABLE jobs add whitelisted BOOLEAN NOT NULL DEFAULT FALSE;
