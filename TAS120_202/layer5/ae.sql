/*
CCDM AE mapping
Notes: Standard mapping to CCDM AE table
*/

WITH included_subjects AS (
    SELECT DISTINCT studyid, siteid, usubjid FROM subject),


    ae_data AS (
                 SELECT "project"::text AS studyid,
                       "SiteNumber"::text AS siteid,
                       "Subject"::text AS usubjid,
                       "AETERM"::text AS aeterm,
                       "AETERM"::text AS aeverbatim,
                       "AETERM"::text AS aebodsys,
                       "AESTDAT"::timestamp without time zone AS aestdtc,
                       "AEENDAT"::timestamp without time zone AS aeendtc,
					   case when("AEGR")= '0' then 'G0'
							when("AEGR")= '1' then 'G1'
							when("AEGR")= '2' then 'G2'
							when("AEGR")= '3' then 'G3'
							when("AEGR")= '4' then 'G4'
							when("AEGR")= '5' then 'G5'
							end ::text AS aesev,
                       case when lower(ae."AESER")='yes' then 'Serious' 
							when lower(ae."AESER")='no' then 'Non-Serious' 
							else 'Unknown' end::text AS aeser,
					   CASE WHEN ae."AEREL" IN ('possibly related','definitely related','probably related','Related') THEN 'Yes'
							WHEN ae."AEREL" IN('unrelated','Not Reasonably Possible','Not Related') THEN 'No'
							ELSE '' END::text as aerelnst,
                       ROW_NUMBER () OVER (PARTITION BY "project", ae."SiteNumber", ae."Subject" ORDER BY ae."AESTDAT")::int AS aeseq,
                       "AESTDAT"::timestamp without time zone AS aesttm,
                       "AEENDAT"::timestamp without time zone AS aeentm,
					   null::text AS aellt,
					   null::int AS aelltcd,
					   null::int AS aeptcd,
					   null::text AS aehlt,
					   null::int AS aehltcd,
					   null::text AS aehlgt,
					   null::int AS aehlgtcd,
					   null::int AS aebdsycd,
					   null::text AS aesoc,
					   null::int AS aesoccd,
					   coalesce("AEACTSN" ,"AEACTSDR" ,"AEACTSID" ,"AEACTSDQ") ::text  AS aeacn
				FROM "tas120_202"."AE" ae)



SELECT
        /*KEY (ae.studyid || '~' || ae.siteid || '~' || ae.usubjid)::text AS comprehendid, KEY*/
        ae.studyid::text AS studyid,
        ae.siteid::text AS siteid,
        ae.usubjid::text AS usubjid,
        ae.aeterm::text AS aeterm,
        ae.aeverbatim::text AS aeverbatim,
        ae.aebodsys::text AS aebodsys,
        ae.aestdtc::timestamp without time zone AS aestdtc,
        ae.aeendtc::timestamp without time zone AS aeendtc,
        ae.aesev::text AS aesev,
        ae.aeser::text AS aeser,
        ae.aerelnst::text AS aerelnst,
        ae.aeseq::int AS aeseq,
        ae.aesttm::time without time zone AS aesttm,
        ae.aeentm::time without time zone AS aeentm,
		ae.aellt::text AS aellt,
		ae.aelltcd::int AS aelltcd,
		ae.aeptcd::int AS aeptcd,
		ae.aehlt::text AS aehlt,
		ae.aehltcd::int AS aehltcd,
		ae.aehlgt::text AS aehlgt,
		ae.aehlgtcd::int AS aehlgtcd,
		ae.aebdsycd::int AS aebdsycd,
		ae.aesoc::text AS aesoc,
		ae.aesoccd::int AS aesoccd,
		ae.aeacn::text  AS aeacn
        /*KEY , (ae.studyid || '~' || ae.siteid || '~' || ae.usubjid || '~' || ae.aeseq)::text  AS objectuniquekey KEY*/
        /*KEY , now()::timestamp without time zone AS comprehend_update_time KEY*/
FROM ae_data ae
JOIN included_subjects s ON (ae.studyid = s.studyid AND ae.siteid = s.siteid AND ae.usubjid = s.usubjid);