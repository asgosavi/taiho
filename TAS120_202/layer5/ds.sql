/*
CCDM DS mapping
Notes: Standard mapping to CCDM DS table
*/

WITH included_subjects AS (
                SELECT DISTINCT studyid, siteid, usubjid FROM subject ),

     ds_data AS (
	            SELECT Distinct dm."project"::text AS studyid,
								dm."SiteNumber"::text AS siteid,
								dm."Subject"::text AS usubjid,
								1.0::NUMERIC AS dsseq, 
								'All Subjects'::text AS dscat,
								'All Subjects'::text AS dsterm,
								null::DATE AS dsstdtc,
								null::text AS dsscat 
				from "tas120_202"."DM" dm
				
				union all 
				
				--Disposition Event: Consented
				
				/*SELECT  enr."project"::text AS studyid,
						enr."SiteNumber"::text AS siteid,
						enr."Subject"::text AS usubjid,
						2.0::NUMERIC AS dsseq, 
						'Consent'::text AS dscat,
						'Consented'::text AS dsterm,
						enr."MinCreated" ::DATE AS dsstdtc,
						null::text AS dsscat 
				from "tas120_202"."ENR" enr*/
				SELECT  dm."project"::text AS studyid,
						dm."SiteNumber"::text AS siteid,
						dm."Subject"::text AS usubjid,
						2.0::NUMERIC AS dsseq, 
						'Consent'::text AS dscat,
						'Consented'::text AS dsterm,
						dm."DMICDAT" ::DATE AS dsstdtc,
						null::text AS dsscat 
				from "tas120_202"."DM" dm
				where ("project","SiteNumber", "Subject", "serial_id")
				in ( select 	"project","SiteNumber", "Subject", max(serial_id)  as serial_id
					 from 		"tas120_202"."DM"
					 group by 	"project","SiteNumber", "Subject")
				
				union all 
				
				--Disposition Event: Failed Screen
				
				SELECT  ie."project"::text AS studyid,
						ie."SiteNumber"::text AS siteid,
						ie."Subject"::text AS usubjid,
						2.1::NUMERIC AS dsseq, 
						'Enrollment'::text AS dscat,
						'Failed Screen'::text AS dsterm,
						COALESCE(ie."MinCreated" ,ie."RecordDate")::DATE AS dsstdtc,
						case when nullif("IECAT",'') is null and nullif("IETESTCD",'') is null
								then null
							else concat(concat("IECAT",' '), "IETESTCD") 
						end::TEXT AS dsscat
				from "tas120_202"."IE" as ie
				where ie."IEYN" = 'No'
				
				union all 
				
				--Disposition Event: Enrollment
				
				SELECT  enr."project"::text AS studyid,
						enr."SiteNumber"::text AS siteid,
						enr."Subject"::text AS usubjid,
						3.0::NUMERIC AS dsseq,
						'Enrollment'::text AS dscat,
						'Enrolled'::text AS dsterm,
						enr."ENRDAT"::DATE AS dsstdtc,
						null::text AS dsscat  
				from "tas120_202"."ENR" enr
				where enr."ENRYN"='Yes'
				
				union all 
				
				--Disposition Event: Withdrawn (EOS)
				
				SELECT  eos."project"::text AS studyid,
						eos."SiteNumber"::text AS siteid,
						eos."Subject"::text AS usubjid,
						4.1::NUMERIC AS dsseq, 
						'Completion'::text AS dscat,
						'Withdrawn'::text AS dsterm,
						eos."EOSDAT"::DATE AS dsstdtc,
						null::text AS dsscat  
				from "tas120_202"."EOS" eos
				where eos."EOSREAS" <> 'End of study per 2 protocol'
				
				union all 
				
				--Disposition Event: Withdrawn (EOT)
				
				SELECT  eot."project"::text AS studyid,
						eot."SiteNumber"::text AS siteid,
						eot."Subject"::text AS usubjid,
						4.1::NUMERIC AS dsseq, 
						'Completion'::text AS dscat,
						'Withdrawn'::text AS dsterm,
						eot."EOTDAT"::DATE AS dsstdtc,
						null::text AS dsscat  
				from "tas120_202"."EOT" eot
				where eot."EOTREAS" <> 'End of study per 2 protocol'
				
				union all 
				
				--Disposition Event: Study Completion
				
				SELECT  eos."project"::text AS studyid,
						eos."SiteNumber"::text AS siteid,
						eos."Subject"::text AS usubjid,
						5.0::NUMERIC AS dsseq, 
						'Completion'::text AS dscat,
						'Completed'::text AS dsterm,
						eos."EOSDAT"::DATE AS dsstdtc,
						null::text AS dsscat
				from "tas120_202"."EOS" eos
				where eos."EOSREAS" <> 'End of study per 2 protocol'
				
				)

SELECT
        /*KEY (ds.studyid || '~' || ds.siteid || '~' || ds.usubjid)::TEXT AS comprehendid, KEY*/
        ds.studyid::TEXT AS studyid,
        ds.siteid::TEXT AS siteid,
        ds.usubjid::TEXT AS usubjid,
        ds.dsseq::NUMERIC AS dsseq, --deprecated
        ds.dscat::TEXT AS dscat,
        ds.dsscat::TEXT AS dsscat,
        ds.dsterm::TEXT AS dsterm,
        ds.dsstdtc::DATE AS dsstdtc
        /*KEY , (ds.studyid || '~' || ds.siteid || '~' || ds.usubjid || '~' || ds.dsseq)::TEXT  AS objectuniquekey KEY*/
        /*KEY , now()::TIMESTAMP WITH TIME ZONE AS comprehend_update_time KEY*/
FROM ds_data ds
JOIN included_subjects s ON (ds.studyid = s.studyid AND ds.siteid = s.siteid AND ds.usubjid = s.usubjid);  
