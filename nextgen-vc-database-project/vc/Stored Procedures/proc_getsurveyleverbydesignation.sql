
CREATE PROCEDURE [vc].[proc_getsurveyleverbydesignation](
    @designation_id int,
    @query_all bit
) AS
BEGIN
	--Sanity check------------------------------------------------------------

	IF IsNull(@query_all,0) = 0 AND IsNull(@designation_id,0) = 0 
		RETURN;

	if IsNull(@query_all,0) = 1 and IsNull(@designation_id,0) = 0 begin
		select 
		a.survey_lever_id, 
		a.name as survey_lever_name, 
		a.type as survey_lever_type,
		avg(b.score) as score, 
		null as designation_id, 
		b.standard_text as survey_description,
		null as designation_name,
		avg(b.benchmark) as benchmark
		  from vc.survey_lever a
		  join vc.procurement_survey_lever b on a.survey_lever_id = b.survey_lever_id
		  join vc.designation c on b.designation_id = c.designation_id
		 group by 
		 a.type, 
		 a.survey_lever_id, 
		 a.name,
		 b.standard_text
		 order by a.type
	end
	else begin
		select 
		a.survey_lever_id, 
		a.name as survey_lever_name, 
		a.type as survey_lever_type,
		avg(b.score) as score,
		c.designation_id, 
		b.standard_text as survey_description,  ---------
		c.name as designation_name,
		avg(b.benchmark) as benchmark
		  from vc.survey_lever a
		  join vc.procurement_survey_lever b on a.survey_lever_id = b.survey_lever_id
		  join vc.designation c on b.designation_id = c.designation_id
		 where c.designation_id = case when @designation_id is null then c.designation_id else @designation_id end
		 group by a.survey_lever_id, a.name, a.type, c.designation_id, c.name,b.standard_text
		 order by c.name, a.type, a.name
	end
END
