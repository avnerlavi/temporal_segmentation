# temporal_segmentation

This porject demonstrated the use of spatio-temporal lateral facilitation in several manners, mainly ultrasound enhancement and running man enhancement.

## Setup
1. Pull git to specified folder "root"
2. set the root folder as an enviroment variable: 
<br><b> setenv('TemporalSegmentation',"path to root"); </b>

## Tutorial
### Run detail enhancement on a single video
1. open 3dGabor\detail_enhancement_video_3d.m
2. setup line 2-9 as prefered:
 - ultrasound_enhancement - uses postproccessing methods for ultrasound enhancement
 - dump_movies - saves the results of the run in the results folder
 - generatePyrFlag - defrecated, uses preproccessing methods for running man (leave on false)
 - elevationHalfAngle - 2-vector of a scalar to decide the 3D elevation range for the algorithm in degrees, if elevationHalfAngle is a 2-vector - the first entry is the minimal range and the second is the maximal range, if elevationHalfAngle is a scalar - sets the minimal angle to zero and the maximal to elevationHalfAngle.
 <br> Example: elevationHalfAngle = [0,90] - the algorithm will use the full elevation range.
 - resizeFactors - 3-vector of the resize factors for the video in x-y-t.The factors are a ratio of the videos size (0 to 1)
 <br> Example: resizeFactors = [1,1,1] will use the full resolution.

3.Set InFileDir in line 12 to be the path for the input video.

4.notice line 21 is a fix for screen jittering in ultrasound vids - remove if nescesary.

5.Change CCLF params (lines 25-36) as follows:
- numOfScales - number of different video scales for the algorithm
- azimuthNum - number of different azimuth angles(spatial direction) for the algorithm edge detection orientations
- elevationNum - number of different elevation angles(temporal direction)  the algorithm edge detection orientations
- eccentricity - constant for weighting the temporal or the spatial enhancement (1 - no bias)
- activationThreshold - threshold for the lateral facilitation
- facilitationLengths - the length of the facilitation's additive signal
- alpha - a number between 0-1 to control the strength of the original edges enhancement (0 - full enhancement,1-no original edge enhancement, only lateral facilitation)
- m1 - winner takes all mechanism for the orientation (1- no mechanism, >1 - winner takes all effect, <1 - reverse effect)
- m2 - winner takes all mechanism for the scales (1- no mechanism, >1 - winner takes all effect, <1 - reverse effect)
- normQ -  winner takes all mechanism for the dominant orientation detection (1- no mechanism, >1 - winner takes all effect, <1 - reverse effect)

6.Change lines 59-61, only relevant if ultrasound_enhancement is true:
- beta - beta factoring strength (s-> s/(1+beta*I))
- gamma - gamma factoring strengh (s-> s^gamma)
- gain - response gain (s-> s*gain)

7. Run the code, results should appear in "results\3dGabor\detail_enhancemnt"
- movie_detail_enhanced_3d_minmax - the response with minMax normaization ((x-min)/(max-min))
- movie_detail_enhanced_3d_abs - the absolute response , mainly for visual inspection
- movie_combined_norm - combined video with minMax normaization
- movie_combined_clipped - combined video with values outside the [0,1] range clipped
- comparison_norm - comparison of the original video with movie_combined_norm
- comparison_clipped - comparison of the original video with movie_combined_clipped
- params - parameter files for ducomentation of the results
