/*
CCDM Site mapping
Client:taiho
Limits added for PR build efficiency (not applied for standard builds)
Notes: Standard mapping to CCDM Site table
*/

WITH included_studies AS (
                SELECT studyid FROM study ),

   site_data AS (
                SELECT  'TAS120_202'::text AS studyid,
                        "oid"::text AS siteid,
                        "name"::text AS sitename,
                        'IQVIA'::text AS croid,
                        'IQVIA'::text AS sitecro,
						null::text AS siteinvestigatorname,
						null::text AS sitecraname,
                        case 
							when length(trim(SUBSTRING( "name",1, POSITION('_' in "name")-1)))=3
								 THEN CASE 
										   when left(SUBSTRING( "name",1, POSITION('_' in "name")-1),1)='1' then 			 'US'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '200' and '249' then 'UK'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '250' and '299' then 'SE'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '300' and '349' then 'ES'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '350' and '399' then 'NL'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '400' and '449' then 'IT'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '450' and '499' then 'DE'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '500' and '549' then 'FR'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '550' and '599' then 'BE'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '600' and '649' then 'TR'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '650' and '699' then 'SG'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '700' and '749' then 'KR'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '750' and '799' then 'HK'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '800' and '849' then 'JP'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '900' and '949' then 'PT'
									 end
						else 'US' end::text AS sitecountry,
                        case 
							when length(trim(SUBSTRING( "name",1, POSITION('_' in "name")-1)))=3
								 THEN CASE 
										   when left(SUBSTRING( "name",1, POSITION('_' in "name")-1),1)='1' then 'North America'			 
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '200' and '249' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '250' and '299' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '300' and '349' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '350' and '399' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '400' and '449' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '450' and '499' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '500' and '549' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '550' and '599' then 'Europe'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '600' and '649' then 'Middle East, North Africa, and Greater Arabia'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '650' and '699' then 'Asia'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '700' and '749' then 'Asia'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '750' and '799' then 'Asia'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '800' and '849' then 'Asia'
										   when SUBSTRING( "name",1, POSITION('_' in "name")-1) between '900' and '949' then 'Europe'
									 end
						else 'North America' end::text AS siteregion,
                        "effectivedate"::date AS sitecreationdate,
                        "effectivedate"::date AS siteactivationdate,
                        null::date AS sitedeactivationdate,
                        null::text AS siteaddress1,
                        null::text AS siteaddress2,
                        null::text AS sitecity,
                        null::text AS sitestate,
                        null::text AS sitepostal,
                        null::text AS sitestatus,
                        null::date AS sitestatusdate 
				FROM "tas120_202"."__sites" 
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