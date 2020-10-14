/*
CCDM DS mapping
Notes: Standard mapping to CCDM DS table
*/

WITH included_subjects AS (
                SELECT DISTINCT studyid, siteid, usubjid FROM subject ),

ds_data AS (

----Disposition Event: All Subjects----

SELECT  dm."project"::text AS studyid,
dm."SiteNumber"::text AS siteid,
dm."Subject"::text AS usubjid,
1.0::NUMERIC AS dsseq, 
'All Subjects'::text AS dscat,
'All Subjects'::text AS dsterm,
null::DATE AS dsstdtc,
null::text AS dsscat 
from tas3681_101."DM" dm

union all 

--Disposition Event: Consented

SELECT  dm."project"::text AS studyid,
dm."SiteNumber"::text AS siteid,
dm."Subject"::text AS usubjid,
2.0::NUMERIC AS dsseq, 
'Consent'::text AS dscat,
'Consented'::text AS dsterm,
dm."DMICDAT"::DATE AS dsstdtc,
null::text AS dsscat 
from tas3681_101."DM" dm

union all 

--Disposition Event: Failed Screen

SELECT  ie."project"::text AS studyid,
ie."SiteNumber"::text AS siteid,
ie."Subject"::text AS usubjid,
2.1::NUMERIC AS dsseq, 
'Enrollment'::text AS dscat,
'Failed Screen'::text AS dsterm,
COALESCE(ie."MinCreated" ,ie."RecordDate")::DATE AS dsstdtc,
case	
	when	"IEYN" = 'Yes' and "IERANDYN" = 'No'	
		then	"IERANDN"
	when	"IEYN"='No'	
		then 
			case 
				when nullif("IECAT",'') is null and nullif("IETESTCD",'') is null
					then null 
				else concat(concat("IECAT",' '),"IETESTCD") 
				end	
		end::text AS dsscat
from tas3681_101."IE" as ie
where (ie."IEYN" = 'No' or  ("IEYN" = 'Yes' and "IERANDYN" = 'No'))	
and	("project","SiteNumber", "Subject", "serial_id")
	in (
	
	select "project","SiteNumber", "Subject", max(serial_id)  as serial_id
	from tas3681_101."IE"
	group by 1,2,3
	)
  
union all 

--Disposition Event: Enrollment

SELECT  ie."project"::text AS studyid,
ie."SiteNumber"::text AS siteid,
ie."Subject"::text AS usubjid,
3.0::NUMERIC AS dsseq,
'Enrollment'::text AS dscat,
'Enrolled'::text AS dsterm,
min(ex."EXOSTDAT")::DATE AS dsstdtc,
null::text AS dsscat  
from tas3681_101."IE" ie
left join tas3681_101."EXO" ex
on ie."project"=ex."project" and ie."SiteNumber"=ex."SiteNumber" and ie."Subject"=ex."Subject"
where ie."IERANDYN" = 'Yes'
group by  ie."project", ie."SiteNumber", ie."Subject"


union all 

--Disposition Event: Early EOT

SELECT  ds."project"::text AS studyid,
ds."SiteNumber"::text AS siteid,
ds."Subject"::text AS usubjid,
4.01::NUMERIC AS dsseq, 
'Treatment'::text AS dscat,
'Early EOT'::text AS dsterm,
ds."DSDAT"::DATE AS dsstdtc,
ds."DSREAS"::text AS dsscat  
from tas3681_101."DS" ds
where ("project","SiteNumber", "Subject", "serial_id")
	in (
	select "project","SiteNumber", "Subject", max(serial_id)  as serial_id
	from tas3681_101."DS"
	group by 1,2,3
	)

union all 

--Disposition Event: Withdrawn

SELECT  es."project"::text AS studyid,
es."SiteNumber"::text AS siteid,
es."Subject"::text AS usubjid,
4.1::NUMERIC AS dsseq, 
'Completion'::text AS dscat,
'Withdrawn'::text AS dsterm,
es."EOSDAT"::DATE AS dsstdtc,
null::text AS dsscat  
from tas3681_101."EOS" es
where es."EOSREAS" <> 'Study Completion'


union all 

--Disposition Event: Study Completion

SELECT  es."project"::text AS studyid,
es."SiteNumber"::text AS siteid,
es."Subject"::text AS usubjid,
5.0::NUMERIC AS dsseq, 
'Completion'::text AS dscat,
'Completed'::text AS dsterm,
es."EOSDAT"::DATE AS dsstdtc,
es."EOSREAS"::text AS dsscat  
from tas3681_101."EOS" es
where es."EOSREAS" = 'Study Completion'


)

SELECT
        /*KEY (ds.studyid || '~' || ds.siteid || '~' || ds.usubjid)::text AS comprehendid,  KEY*/
        ds.studyid::text AS studyid,
        ds.siteid::text AS siteid,
        ds.usubjid::text AS usubjid,
        ds.dsseq::NUMERIC AS dsseq,
        ds.dscat::text AS dscat,
        ds.dsscat::text AS dsscat,
        ds.dsterm::text AS dsterm,
        ds.dsstdtc::DATE AS dsstdtc
       /*KEY  , (ds.studyid || '~' || ds.siteid || '~' || ds.usubjid || '~' || ds.dsseq)::text  AS objectuniquekey KEY*/
        /*KEY , now()::TIMESTAMP WITH TIME ZONE AS comprehend_update_time KEY*/
FROM ds_data ds
JOIN included_subjects s ON (ds.studyid = s.studyid AND ds.siteid = s.siteid AND ds.usubjid = s.usubjid);