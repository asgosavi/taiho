/*
CCDM Site mapping
Client:taiho
Limits added for PR build efficiency (not applied for standard builds)
Notes: Standard mapping to CCDM Site table
*/

WITH included_studies AS (
                SELECT studyid FROM study ),

    site_data AS (
                SELECT  'TAS120_201'::text AS studyid,
                        "oid"::text AS siteid,
                        "name"::text AS sitename,
                        'UBC'::text AS croid,
                        'UBC'::text AS sitecro,
                        case 
							when length(trim(SUBSTRING( "name",1, POSITION('_' in "name")-1)))=3
								THEN CASE when left(SUBSTRING( "name",1, POSITION('_' in "name")-1),1)='0' then 'US'
										  when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '100' and '149' then 'UK'
										  when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '150' and '199' then 'ES'
										  when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '200' and '249' then 'PT'
										  when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '250' and '299' then 'FR'
										  when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '300' and '349' then 'IT'
										  when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '350' and '399' then 'CA'
									 end
						else 'US' end::text AS sitecountry,
                        case 
							when length(trim(SUBSTRING( "name",1, POSITION('_' in "name")-1)))=3
								 THEN CASE when left(SUBSTRING( "name",1, POSITION('_' in "name")-1),1)='0' then 'North America'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '100' and '149' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '150' and '199' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '200' and '249' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '250' and '299' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '300' and '349' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '350' and '399' then 'North America'
									 end
						else 'North America' end::text AS siteregion,
                        "effectivedate"::date AS sitecreationdate,
                        "effectivedate"::date AS siteactivationdate,
                        null::date AS sitedeactivationdate,
                        null::text AS siteinvestigatorname,
                        null::text AS sitecraname,
                        null::text AS siteaddress1,
                        null::text AS siteaddress2,
                        null::text AS sitecity,
                        null::text AS sitestate,
                        null::text AS sitepostal,
                        null::text AS sitestatus,
                        null::date AS sitestatusdate 
						from tas120_201."__sites"
						/*LIMIT LIMIT 100 LIMIT*/)

SELECT 
        /*KEY (s.studyid || '~' || s.siteid)::text AS comprehendid, KEY*/
        s.studyid::text AS studyid,
        s.siteid::text AS siteid,
        s.sitename::text AS sitename,
        s.croid::text AS croid,
        s.sitecro::text AS sitecro,
        s.sitecountry::text AS sitecountry,
        s.siteregion::text AS siteregion,
        s.sitecreationdate::date AS sitecreationdate,
        s.siteactivationdate::date AS siteactivationdate,
        s.sitedeactivationdate::date AS sitedeactivationdate,
        s.siteinvestigatorname::text AS siteinvestigatorname,
        s.sitecraname::text AS sitecraname,
        s.siteaddress1::text AS siteaddress1,
        s.siteaddress2::text AS siteaddress2,
        s.sitecity::text AS sitecity,
        s.sitestate::text AS sitestate,
        s.sitepostal::text AS sitepostal,
        s.sitestatus::text AS sitestatus,
        s.sitestatusdate::date AS sitestatusdate
        /*KEY , now()::timestamp with time zone AS comprehend_update_time KEY*/
FROM site_data s 
JOIN included_studies st ON (s.studyid = st.studyid);