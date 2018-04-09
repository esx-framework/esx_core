# esx_joblisting
Simple job listing script, you can specify what jobs you want to be whitelisted.

### Update
If you have an outdated version of ES Extended, you might need to run the following on your SQL server:
`ALTER TABLE jobs add whitelisted BOOLEAN NOT NULL DEFAULT FALSE;`
