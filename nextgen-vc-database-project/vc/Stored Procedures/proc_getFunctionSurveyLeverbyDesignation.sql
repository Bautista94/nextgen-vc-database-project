/****** Object:  StoredProcedure [vc].[proc_getFunctionSurveyLeverbyDesignation]    Script Date: 5/24/2022 9:22:39 AM ******/


CREATE PROCEDURE [vc].[proc_getFunctionSurveyLeverbyDesignation](
    @designation_id int,
    @query_all bit,
	@function_id int
) AS
BEGIN

	/* This part of the code was added as part of BVC-2079 to return one line with NULL values when there's nothing to return */
	DECLARE
		@null_table TABLE --creates table with the same schema as the return output but with only null values
		(
		survey_pillar_name int default null,
		pillar_weighting int default null,
		survey_lever_id int default null,
		survey_lever_name int default null,
		lever_weighting_within_pillar int default null,
		score int default null,
		designation_id int default null,
		designation_name int default null,
		function_id int default null,
		function_name int default null,
		lever_description int default null
		)
	INSERT INTO @null_table(survey_pillar_name) VALUES (null)


-----Sanity check-----------------------------------------------------------------------------------------

	IF IsNull(@query_all,0) = 0 AND IsNull(@designation_id,0) = 0
		BEGIN
			SELECT * from @null_table
			RETURN
		END;

-----query_all = 1 scenario-------------------------------------------------------------------------------
	IF IsNull(@query_all,0) = 1 AND IsNull(@designation_id,0) = 0 
	BEGIN

		--Checks if there's any data in [vc].[function_survey_lever] for query_all=1 scenario, if there's no data returns table with nulls (BVC-2079)
		IF NOT EXISTS (SELECT * FROM [vc].[function_survey_lever] WHERE function_id = @function_id)
			BEGIN
				SELECT * from @null_table 
				RETURN
			END;

		--Calculates proc_getFunctionSurveyLeverbyDesignation
		WITH pillar_score_by_function_all_designations AS (
			SELECT
				sl.type					AS survey_pillar_name
				,fsl.function_id
			--	,fsl.standard_text as lever_description
				,sum(score)				AS pillar_score_by_function_all_designations
			FROM
				[vc].[function_survey_lever] fsl
				INNER JOIN vc.survey_lever sl
					ON fsl.survey_lever_id = sl.survey_lever_id
			GROUP BY
				sl.type
				,fsl.function_id
		) 
		,total_score_by_function_all_designations AS (
			SELECT
				psfd.function_id
				,sum(psfd.pillar_score_by_function_all_designations)				AS total_score_by_function_all_designations
			FROM
				pillar_score_by_function_all_designations psfd
			GROUP BY
				psfd.function_id
		)
		SELECT
			psfd.survey_pillar_name
			,(CAST(psfd.pillar_score_by_function_all_designations/tsfd.total_score_by_function_all_designations AS numeric(4,3))) AS pillar_weighting
			,fsl.survey_lever_id
			,sl.name					AS survey_lever_name
			,SUM(CAST(fsl.score/psfd.pillar_score_by_function_all_designations AS numeric(4,3)))	AS lever_weighting_within_pillar
			,avg(fsl.score)				AS score
			,NULL						AS designation_id
			,NULL						AS designation_name
			,fsl.function_id
			,f.name						AS function_name
			,fsl.standard_text as lever_description
		FROM
			[vc].[function_survey_lever] fsl
			INNER JOIN vc.survey_lever sl
				ON fsl.survey_lever_id = sl.survey_lever_id
			INNER JOIN vc.[function] f
				ON fsl.function_id = f.function_id
				AND fsl.function_id = ISNULL(@function_id, fsl.function_id)
			INNER JOIN pillar_score_by_function_all_designations psfd
				ON psfd.function_id = fsl.function_id
				AND psfd.survey_pillar_name = sl.type
			INNER JOIN total_score_by_function_all_designations tsfd
				ON tsfd.function_id = fsl.function_id
		WHERE
			fsl.function_id = ISNULL(@function_id, fsl.function_id)
		GROUP BY
			fsl.survey_lever_id
			,sl.name
			,psfd.survey_pillar_name
			,fsl.function_id
			,f.name
			,(CAST(psfd.pillar_score_by_function_all_designations/tsfd.total_score_by_function_all_designations AS numeric(4,3)))
			,fsl.standard_text
	END

-----query_all = 0 scenario-------------------------------------------------------------------------------
	ELSE 
	BEGIN

		--Checks if there's any data in [vc].[function_survey_lever] for query_all = 0 scenario, if there's no data returns table with nulls (BVC-2079)
		IF NOT EXISTS (SELECT * FROM [vc].[function_survey_lever] WHERE designation_id = @designation_id AND function_id = @function_id)
		BEGIN
			SELECT * from @null_table 
			RETURN
		END;

		--Calculates proc_getFunctionSurveyLeverbyDesignation
		WITH pillar_score_by_function_and_designation AS (
			SELECT
				sl.type					AS survey_pillar_name
				,fsl.designation_id
				,fsl.function_id
				,sum(score)				AS pillar_score_by_function_and_designation
			FROM
				[vc].[function_survey_lever] fsl
				INNER JOIN vc.survey_lever sl
					ON fsl.survey_lever_id = sl.survey_lever_id
			WHERE
				fsl.designation_id  = ISNULL(@designation_id,fsl.designation_id)
			GROUP BY
				sl.type
				,fsl.designation_id
				,fsl.function_id
		)
		,total_score_by_function_and_designation AS (
			SELECT
				psfd.function_id
				,psfd.designation_id
				,sum(psfd.pillar_score_by_function_and_designation)				AS total_score_by_function_and_designation
			FROM
				pillar_score_by_function_and_designation psfd
			GROUP BY
				psfd.function_id
				,psfd.designation_id
		)
		SELECT
			psfd.survey_pillar_name
			,CAST(psfd.pillar_score_by_function_and_designation/tsfd.total_score_by_function_and_designation AS numeric(4,3)) AS pillar_weighting
			,fsl.survey_lever_id
			,sl.name					AS survey_lever_name
			,SUM(CAST(fsl.score/psfd.pillar_score_by_function_and_designation AS numeric(4,3)))	AS lever_weighting_within_pillar
			,fsl.score
			,fsl.designation_id
			,d.name						AS designation_name
			,fsl.function_id
			,f.name						AS function_name
			,fsl.standard_text as lever_description
		FROM
			[vc].[function_survey_lever] fsl
			INNER JOIN vc.survey_lever sl
				ON fsl.survey_lever_id = sl.survey_lever_id
			INNER JOIN vc.designation d
				ON fsl.designation_id = d.designation_id
			INNER JOIN vc.[function] f
				ON fsl.function_id = f.function_id
			INNER JOIN pillar_score_by_function_and_designation psfd
				ON psfd.designation_id = fsl.designation_id
				AND psfd.function_id = fsl.function_id
				AND psfd.survey_pillar_name = sl.type
			INNER JOIN total_score_by_function_and_designation tsfd
				ON tsfd.designation_id = fsl.designation_id
				AND tsfd.function_id = fsl.function_id
		WHERE
			fsl.function_id = ISNULL(@function_id, fsl.function_id)
		GROUP BY
			psfd.survey_pillar_name
			,CAST(psfd.pillar_score_by_function_and_designation/tsfd.total_score_by_function_and_designation AS numeric(4,3))
			,fsl.survey_lever_id
			,sl.name
			,fsl.score
			,fsl.designation_id
			,d.name	
			,fsl.function_id
			,f.name		
			,fsl.standard_text

	END
----------------------------------------------------------------------------------------------------------
END
