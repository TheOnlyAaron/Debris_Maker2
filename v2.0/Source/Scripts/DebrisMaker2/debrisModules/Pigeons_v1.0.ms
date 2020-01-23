--*****************************************************
-- Tool part of the DebrisMaker 2.0 by
-- Aaron Dabelow, theonlyaaron@gmail.com
--*****************************************************
-- HISTORY:
--- version 1.0 : 03.12.2012  >> Created					  
--- version 1.0 : 07.06.2013  >> Created		
--*****************************************************

birdsPigeonModuleVer = 1.0
try(removeSubRollout debrisMaker.theSubrollout birdsPigeonModule)catch()

rollout birdsPigeonModule ("Birds - Pigeon v" + (birdsPigeonModuleVer as string))
(
	groupbox lookGroupbox "Look"  width:177 pos:[5,5] height:40 --offset:[-8,0]
		checkbox createMaterialCheck "Create Material" pos:[14,23] checked:true
	groupbox animationGroupbox "Animation" pos:[5,50] height:40 width:177-- offset:[-8,0]
		dropdownlist animationDDL "" width:165 pos:[12,64] items:#(" casual flight"," fast flight")
	groupbox particlesGroupbox "Particles" width:177 height:60 pos:[5,94]
		checkbox createPFCheck "Create Particle Flow" pos:[13,110] checked:true
		spinner numberOfBirdsSpinner "" range:[1,50,15] type:#integer pos:[12,130] width:50
		label numberOfBirdsLabel " : Number of birds" offset:[12,-20]
	groupbox generationGroupbox "Generation" pos:[5,163] height:80 width:177
		button GenerateButton "<<  Generate  >>" width:164 height:30 offset:[-1,-70]
		progressbar theProgressGroup width:165 height:6 offset:[-3,0] value:0
		label progressLabel " status: ready" offset:[-1,-5] style_sunkenedge:true width:165 height:16
	
	on createPFCheck changed state do
	(
		if createPFCheck.checked == true then
			(
			numberOfBirdsSpinner.enabled = true	
			numberOfBirdsLabel.enabled = true	
			)
			else(
			numberOfBirdsSpinner.enabled = false	
			numberOfBirdsLabel.enabled = false	
			)
	)

	on GenerateButton pressed do
		(
			
		timerStart = timeStamp()
			
		try(
			progressLabel.text = " status: preparing scene"
			makeMaterials = createMaterialCheck.checked
			makeParticleFlow = createPFCheck.checked
			NumberOfBirds = NumberOfBirdsSpinner.value
			theProgressGroup.value = 0
			
			slidertime = 0

			disablesceneredraw()
			max modify mode
			(
			global themesh = mesh vertices:#([2.5842,7.90597,2.04517], [1.76896,8.60528,2.3266], [-1.76896,8.60528,2.3266], [-2.5842,7.90597,2.04517], [-1.76406,8.63139,2.21636], [1.76406,8.63139,2.21636], [1.39865,4.18796,1.06249], [0.940779,4.14563,1.66556], [-0.940779,4.14563,1.66556], [-1.39865,4.18796,1.06249], [-0.935681,4.33768,0.473879], [0.935681,4.33768,0.473879], [1.80654,2.84966,0.65138], [1.21558,2.63582,1.74032], [-1.21558,2.63582,1.74032], [-1.80654,2.84966,0.65138], [-1.20815,3.05668,-0.378835], [1.20815,3.05668,-0.378835], [2.59214,1.55294,0.329002], [1.73849,1.42121,1.80315], [-1.73849,1.42121,1.80315], [-2.59214,1.55294,0.329002], [-1.73651,1.68067,-1.10675], [1.73651,1.68067,-1.10675], [2.59214,7.07672e-007,0.243288], [1.7492,7.31705e-007,1.83522], [-1.7492,7.31502e-007,1.83522], [-2.59214,7.07672e-007,0.243287], [-1.72682,7.05346e-007,-1.20295], [1.72682,7.05114e-007,-1.20295], [2.12587,-1.23653,0.458236], [1.42952,-1.04539,1.77384], [-1.42952,-1.04539,1.77384], [-2.12587,-1.23653,0.458236], [-1.42438,-1.44012,-0.790522], [1.42438,-1.44012,-0.790522], [1.52346,-2.35533,0.88317], [1.02529,-2.05065,1.85336], [-1.02529,-2.05065,1.85336], [-1.52346,-2.35533,0.88317], [-1.0247,-2.65324,-0.0584441], [1.0247,-2.65324,-0.058444], [1.09136,-4.74416,2.13772], [0.723446,-4.74009,2.71473], [-0.723446,-4.74009,2.71473], [-1.09136,-4.74416,2.13772], [-0.760945,-4.76067,1.52808], [0.760945,-4.76067,1.52808], [0,-6.13235,1.36436], [0.843356,-4.09785,2.74605], [1.27282,-4.1928,2.05375], [-0.843355,-4.09785,2.74605], [-1.27282,-4.1928,2.05375], [-0.872146,-4.30658,1.30317], [0.872146,-4.30658,1.30317], [0.270563,-5.53826,1.87288], [0.405815,-5.40392,1.70717], [-0.270563,-5.53826,1.87288], [-0.405816,-5.40392,1.70717], [-0.269189,-5.33314,1.52107], [0.269189,-5.33314,1.52107], [1.19589,-3.25364,1.55461], [0.78196,-3.08737,2.26242], [-0.78196,-3.08738,2.26242], [-1.19589,-3.25364,1.55461], [-0.823697,-3.43999,0.801792], [0.823697,-3.43999,0.801792], [0.97121,5.66044,1.74171], [1.43545,5.55851,1.47073], [-0.97121,5.66044,1.74171], [-1.43545,5.55851,1.47073], [-0.958708,5.67431,1.22039], [0.958708,5.67431,1.22039], [0,9.2759,2.50094], [-1.48496e-007,4.1761,1.97631], [0,9.37143,2.39848], [0,4.47129,0.187035], [-1.80304e-007,2.53044,2.28702], [0,3.16888,-0.921944], [0,1.35606,2.53574], [0,1.74901,-1.86497], [-1.40071e-007,7.54155e-007,2.6377], [0,7.15256e-007,-1.95798], [-1.99676e-007,-0.956913,2.43408], [1.40071e-007,-1.55691,-1.45283], [-2.80142e-007,-1.89905,2.34472], [0,-2.8179,-0.56579], [0,-4.73186,3.01562], [0,-4.72824,1.16704], [0,-4.05384,3.08804], [0,-4.37377,0.880713], [0,-5.57844,2.01913], [0,-5.2294,1.39521], [-1.48892e-007,-3.01185,2.60645], [0,-3.55003,0.380877], [0,5.82187,1.9053], [0,5.68287,1.30727], [1.15351,6.80095,2.04986], [-1.15351,6.80095,2.04986], [-1.74338,6.5269,1.66844], [-1.13164,6.87269,1.60929], [1.13164,6.87269,1.60929], [1.74338,6.5269,1.66844], [0,7.11522,2.22947], [0,6.82579,1.8103], [1.48415,7.9095,2.29911], [-1.48415,7.9095,2.29911], [-2.24005,7.42455,1.8882], [-1.4672,8.03381,1.91038], [1.4672,8.03381,1.91038], [0,8.40529,2.51504], [0,8.22521,2.04141], [2.24005,7.42455,1.8882], [0.508506,-5.27412,2.40298], [-0.508506,-5.27412,2.40298], [-0.758046,-5.20045,2.01047], [-0.508619,-5.16164,1.61505], [0.508619,-5.16164,1.61505], [0.758046,-5.20045,2.01047], [-1.36071e-007,-5.29615,2.63576], [0,-5.10475,1.38519]
			)faces:#([1,2,106], [106,113,1], [2,74,111], [111,106,2], [4,108,107], [107,3,4], [4,5,109], [109,108,4], [5,76,112], [112,109,5], [1,113,110], [110,6,1], [7,8,14], [14,13,7], [8,75,78], [78,14,8], [9,10,16], [16,15,9], [10,11,17], [17,16,10], [11,77,79], [79,17,11], [12,7,13], [13,18,12], [13,14,20], [20,19,13], [14,78,80], [80,20,14], [15,16,22], [22,21,15], [16,17,23], [23,22,16], [17,79,81], [81,23,17], [18,13,19], [19,24,18], [19,20,26], [26,25,19], [80,82,26], [26,20,80], [21,22,28], [28,27,21], [22,23,29], [29,28,22], [81,83,29], [29,23,81], [24,19,25], [25,30,24], [25,26,32], [32,31,25], [82,84,32], [32,26,82], [27,28,34], [34,33,27], [28,29,35], [35,34,28], [83,85,35], [35,29,83], [30,25,31], [31,36,30], [31,32,38], [38,37,31], [84,86,38], [38,32,84], [33,34,40], [40,39,33], [34,35,41], [41,40,34], [85,87,41], [41,35,85], [36,31,37], [37,42,36], [63,50,51], [51,62,63], [94,90,50], [50,63,94], [64,65,53], [53,52,64], [65,66,54], [54,53,65], [66,95,91], [91,54,66], [62,51,55], [55,67,62], [43,44,114], [114,119,43], [44,88,120], [120,114,44], [46,116,115], [115,45,46], [47,117,116], [116,46,47], [89,121,117], [117,47,89], [48,43,119], [119,118,48], [6,2,1], [50,44,43], [43,51,50], [45,88,90], [90,52,45], [46,45,52], [52,53,46], [47,46,53], [53,54,47], [48,89,91], [91,55,48], [51,43,48], [48,55,51], [56,49,57], [49,56,92], [92,58,49], [59,49,58], [60,49,59], [49,60,93], [93,61,49], [57,49,61], [38,63,62], [62,37,38], [64,94,86], [86,39,64], [40,65,64], [64,39,40], [41,66,65], [65,40,41], [67,95,87], [87,42,67], [37,62,67], [67,42,37], [68,8,7], [7,69,68], [9,75,96], [96,70,9], [10,9,70], [70,71,10], [72,11,10], [10,71,72], [12,77,97], [97,73,12], [7,12,73], [73,69,7], [3,107,111], [111,74,3], [6,110,112], [112,76,6], [9,15,78], [78,75,9], [12,18,79], [79,77,12], [15,21,80], [80,78,15], [18,24,81], [81,79,18], [21,27,82], [82,80,21], [24,30,83], [83,81,24], [82,27,33], [33,84,82], [83,30,36], [36,85,83], [84,33,39], [39,86,84], [85,36,42], [42,87,85], [64,52,90], [90,94,64], [67,55,91], [91,95,67], [45,115,120], [120,88,45], [89,48,118], [118,121,89], [5,3,74], [74,76,5], [44,50,90], [90,88,44], [47,54,91], [91,89,47], [63,38,86], [86,94,63], [66,41,87], [87,95,66], [8,68,96], [96,75,8], [11,72,97], [97,77,11], [76,74,2], [2,6,76], [5,4,3], [68,69,103], [103,98,68], [96,68,98], [98,104,96], [100,71,70], [70,99,100], [101,72,71], [71,100,101], [105,97,72], [72,101,105], [69,73,102], [102,103,69], [99,70,96], [96,104,99], [73,97,105], [105,102,73], [98,103,113], [113,106,98], [104,98,106], [106,111,104], [108,100,99], [99,107,108], [101,100,108], [108,109,101], [105,101,109], [109,112,105], [113,103,102], [102,110,113], [107,99,104], [104,111,107], [110,102,105], [105,112,110], [56,57,119], [119,114,56], [92,56,114], [114,120,92], [116,59,58], [58,115,116], [117,60,59], [59,116,117], [121,93,60], [60,117,121], [57,61,118], [118,119,57], [115,58,92], [92,120,115], [61,93,121], [121,118,61]));
			setEdgeVis themesh 1 3 false; setEdgeVis themesh 2 3 false; setEdgeVis themesh 3 3 false; setEdgeVis themesh 4 3 false; setEdgeVis themesh 5 3 false; setEdgeVis themesh 6 3 false; setEdgeVis themesh 7 3 false; setEdgeVis themesh 8 3 false; setEdgeVis themesh 9 3 false; setEdgeVis themesh 10 3 false; setEdgeVis themesh 11 3 false; setEdgeVis themesh 12 3 false; setEdgeVis themesh 13 3 false; setEdgeVis themesh 14 3 false; setEdgeVis themesh 15 3 false; setEdgeVis themesh 16 3 false; setEdgeVis themesh 17 3 false; setEdgeVis themesh 18 3 false; setEdgeVis themesh 19 3 false; setEdgeVis themesh 20 3 false; setEdgeVis themesh 21 3 false; setEdgeVis themesh 22 3 false; setEdgeVis themesh 23 3 false; setEdgeVis themesh 24 3 false; setEdgeVis themesh 25 3 false; setEdgeVis themesh 26 3 false; setEdgeVis themesh 27 3 false; setEdgeVis themesh 28 3 false; setEdgeVis themesh 29 3 false; setEdgeVis themesh 30 3 false; setEdgeVis themesh 31 3 false; setEdgeVis themesh 32 3 false; setEdgeVis themesh 33 3 false; setEdgeVis themesh 34 3 false; setEdgeVis themesh 35 3 false; setEdgeVis themesh 36 3 false; setEdgeVis themesh 37 3 false; setEdgeVis themesh 38 3 false; setEdgeVis themesh 39 3 false; setEdgeVis themesh 40 3 false; setEdgeVis themesh 41 3 false; setEdgeVis themesh 42 3 false; setEdgeVis themesh 43 3 false; setEdgeVis themesh 44 3 false; setEdgeVis themesh 45 3 false; setEdgeVis themesh 46 3 false; setEdgeVis themesh 47 3 false; setEdgeVis themesh 48 3 false; setEdgeVis themesh 49 3 false; setEdgeVis themesh 50 3 false; setEdgeVis themesh 51 3 false; setEdgeVis themesh 52 3 false; setEdgeVis themesh 53 3 false; setEdgeVis themesh 54 3 false; setEdgeVis themesh 55 3 false; setEdgeVis themesh 56 3 false; setEdgeVis themesh 57 3 false; setEdgeVis themesh 58 3 false; setEdgeVis themesh 59 3 false; setEdgeVis themesh 60 3 false; setEdgeVis themesh 61 3 false; setEdgeVis themesh 62 3 false; setEdgeVis themesh 63 3 false; setEdgeVis themesh 64 3 false; setEdgeVis themesh 65 3 false; setEdgeVis themesh 66 3 false; setEdgeVis themesh 67 3 false; setEdgeVis themesh 68 3 false; setEdgeVis themesh 69 3 false; setEdgeVis themesh 70 3 false; setEdgeVis themesh 71 3 false; setEdgeVis themesh 72 3 false; setEdgeVis themesh 73 3 false; setEdgeVis themesh 74 3 false; setEdgeVis themesh 75 3 false; setEdgeVis themesh 76 3 false; setEdgeVis themesh 77 3 false; setEdgeVis themesh 78 3 false; setEdgeVis themesh 79 3 false; setEdgeVis themesh 80 3 false; setEdgeVis themesh 81 3 false; setEdgeVis themesh 82 3 false; setEdgeVis themesh 83 3 false; setEdgeVis themesh 84 3 false; setEdgeVis themesh 85 3 false; setEdgeVis themesh 86 3 false; setEdgeVis themesh 87 3 false; setEdgeVis themesh 88 3 false; setEdgeVis themesh 89 3 false; setEdgeVis themesh 90 3 false; setEdgeVis themesh 91 3 false; setEdgeVis themesh 92 3 false; setEdgeVis themesh 93 3 false; setEdgeVis themesh 94 3 false; setEdgeVis themesh 95 3 false; setEdgeVis themesh 96 3 false; setEdgeVis themesh 98 3 false; setEdgeVis themesh 99 3 false; setEdgeVis themesh 100 3 false; setEdgeVis themesh 101 3 false; setEdgeVis themesh 102 3 false; setEdgeVis themesh 103 3 false; setEdgeVis themesh 104 3 false; setEdgeVis themesh 105 3 false; setEdgeVis themesh 106 3 false; setEdgeVis themesh 107 3 false; setEdgeVis themesh 108 3 false; setEdgeVis themesh 109 3 false; setEdgeVis themesh 111 3 false; setEdgeVis themesh 112 3 false; setEdgeVis themesh 115 3 false; setEdgeVis themesh 116 3 false; setEdgeVis themesh 118 3 false; setEdgeVis themesh 119 3 false; setEdgeVis themesh 120 3 false; setEdgeVis themesh 121 3 false; setEdgeVis themesh 122 3 false; setEdgeVis themesh 123 3 false; setEdgeVis themesh 124 3 false; setEdgeVis themesh 125 3 false; setEdgeVis themesh 126 3 false; setEdgeVis themesh 127 3 false; setEdgeVis themesh 128 3 false; setEdgeVis themesh 129 3 false; setEdgeVis themesh 130 3 false; setEdgeVis themesh 131 3 false; setEdgeVis themesh 132 3 false; setEdgeVis themesh 133 3 false; setEdgeVis themesh 134 3 false; setEdgeVis themesh 135 3 false; setEdgeVis themesh 136 3 false; setEdgeVis themesh 137 3 false; setEdgeVis themesh 138 3 false; setEdgeVis themesh 139 3 false; setEdgeVis themesh 140 3 false; setEdgeVis themesh 141 3 false; setEdgeVis themesh 142 3 false; setEdgeVis themesh 143 3 false; setEdgeVis themesh 144 3 false; setEdgeVis themesh 145 3 false; setEdgeVis themesh 146 3 false; setEdgeVis themesh 147 3 false; setEdgeVis themesh 148 3 false; setEdgeVis themesh 149 3 false; setEdgeVis themesh 150 3 false; setEdgeVis themesh 151 3 false; setEdgeVis themesh 152 3 false; setEdgeVis themesh 153 3 false; setEdgeVis themesh 154 3 false; setEdgeVis themesh 155 3 false; setEdgeVis themesh 156 3 false; setEdgeVis themesh 157 3 false; setEdgeVis themesh 158 3 false; setEdgeVis themesh 159 3 false; setEdgeVis themesh 160 3 false; setEdgeVis themesh 161 3 false; setEdgeVis themesh 162 3 false; setEdgeVis themesh 163 3 false; setEdgeVis themesh 164 3 false; setEdgeVis themesh 165 3 false; setEdgeVis themesh 166 3 false; setEdgeVis themesh 167 3 false; setEdgeVis themesh 168 3 false; setEdgeVis themesh 169 3 false; setEdgeVis themesh 170 3 false; setEdgeVis themesh 171 3 false; setEdgeVis themesh 172 3 false; setEdgeVis themesh 173 3 false; setEdgeVis themesh 174 3 false; setEdgeVis themesh 175 3 false; setEdgeVis themesh 176 3 false; setEdgeVis themesh 177 3 false; setEdgeVis themesh 178 3 false; setEdgeVis themesh 179 3 false; setEdgeVis themesh 180 3 false; setEdgeVis themesh 181 3 false; setEdgeVis themesh 182 3 false; setEdgeVis themesh 183 3 false; setEdgeVis themesh 184 3 false; setEdgeVis themesh 185 3 false; setEdgeVis themesh 186 3 false; setEdgeVis themesh 187 3 false; setEdgeVis themesh 188 3 false; setEdgeVis themesh 189 3 false; setEdgeVis themesh 191 3 false; setEdgeVis themesh 192 3 false; setEdgeVis themesh 193 3 false; setEdgeVis themesh 194 3 false; setEdgeVis themesh 195 3 false; setEdgeVis themesh 196 3 false; setEdgeVis themesh 197 3 false; setEdgeVis themesh 198 3 false; setEdgeVis themesh 199 3 false; setEdgeVis themesh 200 3 false; setEdgeVis themesh 201 3 false; setEdgeVis themesh 202 3 false; setEdgeVis themesh 203 3 false; setEdgeVis themesh 204 3 false; setEdgeVis themesh 205 3 false; setEdgeVis themesh 206 3 false; setEdgeVis themesh 207 3 false; setEdgeVis themesh 208 3 false; setEdgeVis themesh 209 3 false; setEdgeVis themesh 210 3 false; setEdgeVis themesh 211 3 false; setEdgeVis themesh 212 3 false; setEdgeVis themesh 213 3 false; setEdgeVis themesh 214 3 false; setEdgeVis themesh 215 3 false; setEdgeVis themesh 216 3 false; setEdgeVis themesh 217 3 false; setEdgeVis themesh 218 3 false; setEdgeVis themesh 219 3 false; setEdgeVis themesh 220 3 false; setEdgeVis themesh 221 3 false; setEdgeVis themesh 222 3 false; setEdgeVis themesh 223 3 false; setEdgeVis themesh 224 3 false; setEdgeVis themesh 225 3 false; setEdgeVis themesh 226 3 false; setEdgeVis themesh 227 3 false; setEdgeVis themesh 228 3 false; setEdgeVis themesh 229 3 false; setEdgeVis themesh 230 3 false; setEdgeVis themesh 231 3 false; setEdgeVis themesh 232 3 false; setEdgeVis themesh 233 3 false; setEdgeVis themesh 234 3 false; setEdgeVis themesh 235 3 false; setEdgeVis themesh 236 3 false; setEdgeVis themesh 237 3 false; setEdgeVis themesh 238 3 false

			BodyMesh = themesh
			convertToPoly BodyMesh
			
			theProgressGroup.value = 10
			progressLabel.text = " status: creating meshes"
			
			(themesh = mesh vertices:#([-1.60966,-2.76885,-0.0486007], [4.10845,-2.77964,-0.0486007], [-0.995207,0.97937,-0.169273], [3.73897,1.75915,-0.263241], [-1.49644,-1.17378,0.224413], [3.67622,-0.800905,0.345538], [4.11426,-2.00828,0.182275], [-1.58187,-2.18932,0.182275], [-1.27731,0.0597478,0.12311], [3.74477,0.624449,0.244235], [0.655924,1.93713,-0.378723], [0.365328,-2.66718,-0.0486007], [0.4545,-0.723861,0.224413], [0.384185,-1.97192,0.182275], [0.575756,0.73601,0.12311], [2.33575,2.29654,-0.378167], [2.18393,-2.66966,-0.0486007], [2.21301,-0.511437,0.224413], [2.22635,-1.86187,0.182275], [2.30249,1.05697,0.12311], [-1.61492,-2.66662,-0.324225], [4.11403,-2.70244,-0.331073], [-0.990893,0.960601,-0.265149], [3.6827,1.62201,-0.569227], [-1.49508,-1.17666,-0.115572], [3.70883,-0.775136,0.0080882], [4.12597,-1.94799,-0.152132], [-1.58602,-2.12754,-0.152039], [-1.26658,0.0256993,-0.215011], [3.74437,0.559761,-0.0895543], [0.660473,1.90803,-0.471975], [0.360864,-2.57932,-0.328422], [0.456747,-0.731317,-0.115498], [0.380878,-1.92384,-0.154292], [0.585839,0.675197,-0.211255], [2.33538,2.26571,-0.470969], [2.1843,-2.59348,-0.331356], [2.22323,-0.515621,-0.115408], [2.22642,-1.82003,-0.155141], [2.31324,0.989547,-0.209964], [-1.61229,-2.82929,-0.189262], [0.363096,-2.73481,-0.191361], [2.18412,-2.74313,-0.192828], [4.11124,-2.8526,-0.192686]) faces:#([15,11,3], [3,9,15], [14,13,5], [5,8,14], [12,14,8], [8,1,12], [13,15,9], [9,5,13], [11,15,20], [20,16,11], [13,14,19], [19,18,13], [14,12,17], [17,19,14], [15,13,18], [18,20,15], [16,20,10], [10,4,16], [18,19,7], [7,6,18], [19,17,2], [2,7,19], [20,18,6], [6,10,20], [23,31,35], [35,29,23], [25,33,34], [34,28,25], [28,34,32], [32,21,28], [29,35,33], [33,25,29], [40,35,31], [31,36,40], [39,34,33], [33,38,39], [37,32,34], [34,39,37], [38,33,35], [35,40,38], [30,40,36], [36,24,30], [27,39,38], [38,26,27], [22,37,39], [39,27,22], [26,38,40], [40,30,26], [23,29,9], [9,3,23], [31,23,3], [3,11,31], [25,28,8], [8,5,25], [1,8,28], [28,21,41], [1,28,41], [1,41,42], [42,12,1], [29,25,5], [5,9,29], [36,31,11], [11,16,36], [12,42,43], [43,17,12], [30,24,4], [4,10,30], [24,36,16], [16,4,24], [27,26,6], [6,7,27], [7,2,44], [7,44,22], [7,22,27], [17,43,44], [44,2,17], [26,30,10], [10,6,26], [21,32,42], [42,41,21], [32,37,43], [43,42,32], [37,22,44], [44,43,37])); setEdgeVis themesh 1 3 false; setEdgeVis themesh 2 3 false; setEdgeVis themesh 3 3 false; setEdgeVis themesh 4 3 false; setEdgeVis themesh 5 3 false; setEdgeVis themesh 6 3 false; setEdgeVis themesh 7 3 false; setEdgeVis themesh 8 3 false; setEdgeVis themesh 9 3 false; setEdgeVis themesh 10 3 false; setEdgeVis themesh 11 3 false; setEdgeVis themesh 12 3 false; setEdgeVis themesh 13 3 false; setEdgeVis themesh 14 3 false; setEdgeVis themesh 15 3 false; setEdgeVis themesh 16 3 false; setEdgeVis themesh 17 3 false; setEdgeVis themesh 18 3 false; setEdgeVis themesh 19 3 false; setEdgeVis themesh 20 3 false; setEdgeVis themesh 21 3 false; setEdgeVis themesh 22 3 false; setEdgeVis themesh 23 3 false; setEdgeVis themesh 24 3 false; setEdgeVis themesh 25 3 false; setEdgeVis themesh 26 3 false; setEdgeVis themesh 27 3 false; setEdgeVis themesh 28 3 false; setEdgeVis themesh 29 3 false; setEdgeVis themesh 30 3 false; setEdgeVis themesh 31 3 false; setEdgeVis themesh 32 3 false; setEdgeVis themesh 33 3 false; setEdgeVis themesh 34 3 false; setEdgeVis themesh 35 3 false; setEdgeVis themesh 36 3 false; setEdgeVis themesh 37 3 false; setEdgeVis themesh 38 3 false; setEdgeVis themesh 39 3 false; setEdgeVis themesh 40 3 false; setEdgeVis themesh 41 3 false; setEdgeVis themesh 42 3 false; setEdgeVis themesh 43 3 false; setEdgeVis themesh 44 3 false; setEdgeVis themesh 45 3 false; setEdgeVis themesh 46 3 false; setEdgeVis themesh 47 3 false; setEdgeVis themesh 48 3 false; setEdgeVis themesh 49 3 false; setEdgeVis themesh 50 3 false; setEdgeVis themesh 51 3 false; setEdgeVis themesh 52 3 false; setEdgeVis themesh 53 3 false; setEdgeVis themesh 54 3 false; setEdgeVis themesh 55 3 false; setEdgeVis themesh 56 3 false; setEdgeVis themesh 57 1 false; setEdgeVis themesh 57 2 false; setEdgeVis themesh 58 3 false; setEdgeVis themesh 59 3 false; setEdgeVis themesh 60 3 false; setEdgeVis themesh 61 3 false; setEdgeVis themesh 62 3 false; setEdgeVis themesh 63 3 false; setEdgeVis themesh 64 3 false; setEdgeVis themesh 65 3 false; setEdgeVis themesh 66 3 false; setEdgeVis themesh 67 3 false; setEdgeVis themesh 68 3 false; setEdgeVis themesh 69 3 false; setEdgeVis themesh 70 3 false; setEdgeVis themesh 71 3 false; setEdgeVis themesh 72 3 false; setEdgeVis themesh 73 1 false; setEdgeVis themesh 73 3 false; setEdgeVis themesh 74 1 false; setEdgeVis themesh 75 3 false; setEdgeVis themesh 76 3 false; setEdgeVis themesh 77 3 false; setEdgeVis themesh 78 3 false; setEdgeVis themesh 79 3 false; setEdgeVis themesh 80 3 false; setEdgeVis themesh 81 3 false; setEdgeVis themesh 82 3 false; setEdgeVis themesh 83 3 false; setEdgeVis themesh 84 3 false;
			WingBaseMesh = themesh
			convertToPoly WingBaseMesh
			select WingBaseMesh
			subobjectLevel = 1
			WingBaseMesh.EditablePoly.SetSelection #Vertex #{1..44}
			move WingBaseMesh.selectedVerts [-3.53249,0.678576,0]
			subobjectLevel = 0
				
			theProgressGroup.value = 15

			(themesh = mesh vertices:#([-1.65303,-3.14145,-0.341899], [3.58971,-2.107,0], [0.30567,0.105398,-0.262116], [3.75966,1.63638,-0.129412], [-1.18286,-1.67776,-0.297165], [3.92877,-0.40759,0.251647], [3.78123,-1.46089,0.251647], [-1.60378,-2.60891,-0.341283], [-0.573003,-0.919978,-0.270647], [3.83594,0.84859,0.136758], [1.48657,0.626579,-0.177755], [1.93236,-2.43256,0], [0.369397,-1.39447,0.0824149], [2.00454,-1.86688,0.264947], [0.803241,-0.408631,0.0769958], [2.57367,1.11607,-0.129624], [-0.0104931,-2.81421,0], [2.11892,-0.928146,0.218526], [0.0399538,-2.28345,0.134184], [2.32457,0.125668,0.11586], [-1.6431,-3.14229,-0.418428], [3.55806,-1.97293,-0.310846], [0.320422,0.0904197,-0.336372], [3.76507,1.6241,-0.205411], [-1.1678,-1.68389,-0.372608], [3.94228,-0.427244,-0.0875159], [3.7726,-1.41594,-0.0852596], [-1.59135,-2.60866,-0.41745], [-0.558853,-0.928674,-0.346014], [3.85831,0.80599,-0.19982], [1.49729,0.610893,-0.252555], [1.90354,-2.28586,-0.305367], [0.415942,-1.42659,-0.252849], [1.99935,-1.80422,-0.0691891], [0.844134,-0.447326,-0.258311], [2.57982,1.10497,-0.205748], [0.0190374,-2.73645,-0.329667], [2.14004,-0.95556,-0.119709], [0.0790603,-2.25849,-0.202635], [2.3474,0.0873981,-0.221207], [0.016914,-2.88735,-0.222624], [3.58653,-2.15199,-0.213214], [1.9306,-2.47124,-0.210474]) faces:#([15,11,3], [3,9,15], [19,13,5], [5,8,19], [17,19,8], [8,1,17], [13,15,9], [9,5,13], [16,20,10], [10,4,16], [18,14,7], [7,6,18], [14,12,2], [2,7,14], [20,18,6], [6,10,20], [16,11,15], [15,20,16], [18,13,19], [19,14,18], [14,19,17], [17,12,14], [20,15,13], [13,18,20], [23,31,35], [35,29,23], [25,33,39], [39,28,25], [28,39,37], [37,21,28], [29,35,33], [33,25,29], [30,40,36], [36,24,30], [27,34,38], [38,26,27], [22,32,34], [34,27,22], [26,38,40], [40,30,26], [35,31,36], [36,40,35], [39,33,38], [38,34,39], [37,39,34], [34,32,37], [33,35,40], [40,38,33], [23,29,9], [9,3,23], [31,23,3], [3,11,31], [25,28,8], [8,5,25], [28,21,1], [1,8,28], [17,1,21], [21,37,41], [17,21,41], [29,25,5], [5,9,29], [30,24,4], [4,10,30], [24,36,16], [16,4,24], [27,26,6], [6,7,27], [7,2,42], [7,42,22], [7,22,27], [12,43,42], [42,2,12], [26,30,10], [10,6,26], [36,31,11], [11,16,36], [12,17,41], [41,43,12], [32,22,42], [42,43,32], [37,32,43], [43,41,37])); setEdgeVis themesh 1 3 false; setEdgeVis themesh 2 3 false; setEdgeVis themesh 3 3 false; setEdgeVis themesh 4 3 false; setEdgeVis themesh 5 3 false; setEdgeVis themesh 6 3 false; setEdgeVis themesh 7 3 false; setEdgeVis themesh 8 3 false; setEdgeVis themesh 9 3 false; setEdgeVis themesh 10 3 false; setEdgeVis themesh 11 3 false; setEdgeVis themesh 12 3 false; setEdgeVis themesh 13 3 false; setEdgeVis themesh 14 3 false; setEdgeVis themesh 15 3 false; setEdgeVis themesh 16 3 false; setEdgeVis themesh 17 3 false; setEdgeVis themesh 18 3 false; setEdgeVis themesh 19 3 false; setEdgeVis themesh 20 3 false; setEdgeVis themesh 21 3 false; setEdgeVis themesh 22 3 false; setEdgeVis themesh 23 3 false; setEdgeVis themesh 24 3 false; setEdgeVis themesh 25 3 false; setEdgeVis themesh 26 3 false; setEdgeVis themesh 27 3 false; setEdgeVis themesh 28 3 false; setEdgeVis themesh 29 3 false; setEdgeVis themesh 30 3 false; setEdgeVis themesh 31 3 false; setEdgeVis themesh 32 3 false; setEdgeVis themesh 33 3 false; setEdgeVis themesh 34 3 false; setEdgeVis themesh 35 3 false; setEdgeVis themesh 36 3 false; setEdgeVis themesh 37 3 false; setEdgeVis themesh 38 3 false; setEdgeVis themesh 39 3 false; setEdgeVis themesh 40 3 false; setEdgeVis themesh 41 3 false; setEdgeVis themesh 42 3 false; setEdgeVis themesh 43 3 false; setEdgeVis themesh 44 3 false; setEdgeVis themesh 45 3 false; setEdgeVis themesh 46 3 false; setEdgeVis themesh 47 3 false; setEdgeVis themesh 48 3 false; setEdgeVis themesh 49 3 false; setEdgeVis themesh 50 3 false; setEdgeVis themesh 51 3 false; setEdgeVis themesh 52 3 false; setEdgeVis themesh 53 3 false; setEdgeVis themesh 54 3 false; setEdgeVis themesh 55 3 false; setEdgeVis themesh 56 3 false; setEdgeVis themesh 57 3 false; setEdgeVis themesh 58 3 false; setEdgeVis themesh 59 1 false; setEdgeVis themesh 59 2 false; setEdgeVis themesh 60 3 false; setEdgeVis themesh 61 3 false; setEdgeVis themesh 62 3 false; setEdgeVis themesh 63 3 false; setEdgeVis themesh 64 3 false; setEdgeVis themesh 65 3 false; setEdgeVis themesh 66 3 false; setEdgeVis themesh 67 3 false; setEdgeVis themesh 68 3 false; setEdgeVis themesh 69 1 false; setEdgeVis themesh 69 3 false; setEdgeVis themesh 70 1 false; setEdgeVis themesh 71 3 false; setEdgeVis themesh 72 3 false; setEdgeVis themesh 73 3 false; setEdgeVis themesh 74 3 false; setEdgeVis themesh 75 3 false; setEdgeVis themesh 76 3 false; setEdgeVis themesh 77 3 false; setEdgeVis themesh 78 3 false; setEdgeVis themesh 79 3 false; setEdgeVis themesh 80 3 false; setEdgeVis themesh 81 3 false; setEdgeVis themesh 82 3 false;
			WingTipMesh = themesh
			convertToPoly WingTipMesh
			select WingTipMesh
			subobjectLevel = 1
			WingTipMesh.EditablePoly.SetSelection #Vertex #{1..43}
			move WingTipMesh.selectedVerts [-3.50981,0.474659,0]
			subobjectLevel = 0
				
			theProgressGroup.value = 20
				
			if makeMaterials == true then
				(
				progressLabel.text = " status: applying materials"
				select BodyMesh

				MaterialGray = standardMaterial shaderType:1
				MaterialGray.Diffuse = color 140 140 140
				BodyMesh.material = MaterialGray
				WingBaseMesh.material = MaterialGray
				WingTipMesh.material = MaterialGray

				MaterialPurple = standardMaterial shaderType:1
				MaterialPurple.Diffuse = color 114 97 121
				subobjectLevel = 4
				BodyMesh.EditablePoly.SetSelection #Face #{31..36, 84..85}
				$.material = MaterialPurple

				MaterialDark = standardMaterial shaderType:1
				MaterialDark.Diffuse = color 36 43 44
				BodyMesh.EditablePoly.SetSelection #Face #{1..6, 37..67, 74..75, 86..94, 97..106, 115..122}
				$.material = MaterialDark
				subobjectLevel = 0

				select WingBaseMesh
				subobjectLevel = 4
				WingBaseMesh.EditablePoly.SetSelection #Face #{1, 5, 9, 13, 17, 21, 25..26, 31, 33..34}
				$.material = MaterialDark
				subobjectLevel = 0

				select WingTipMesh
				subobjectLevel = 4
				WingTipMesh.EditablePoly.SetSelection #Face #{1..5, 9, 13..17, 21, 25..33, 37}
				$.material = MaterialDark
				subobjectLevel = 0

				clearselection()
			) else ()
			
			theProgressGroup.value = 40
			progressLabel.text = " status: building heirarchy"
				
			WingTipMesh.pos = [-4.872,-0.469,0]
			WingTipMesh.parent = WingBaseMesh
			WingBaseMesh.pos = [-1.416,-0.081,1.491]
			WingTipMesh2 = copy WingTipMesh
			WingBaseMesh2 = copy WingBaseMesh
			WingTipMesh2.parent = WingBaseMesh2

			WingBaseMesh.wirecolor = black
			WingTipMesh.wirecolor = black
			WingBaseMesh2.wirecolor = black
			WingTipMesh2.wirecolor = black
			BodyMesh.wirecolor = black	
			
			theProgressGroup.value = 50

			select #(WingTipMesh, WingBaseMesh)
			tempGroup = group selection name:"TempGroup"
			tempgroup.pivot = [0,0,0]
			scale tempgroup [-1,1,1]
			ungroup tempGroup 
			rotate WingBaseMesh (angleaxis 45 [0,1,0])
			
			theProgressGroup.value = 60
			progressLabel.text = " status: animating"
			
			case animationDDL.selection of
			(
				1: (
					t1 = 8f
					t2 = 12f
					)
				2: (
					t1 = 5f
					t2 = 9f
					)
			)
			
			with animate on 
			(
			sliderTime = t1
			rotate WingBaseMesh (angleaxis -120 [0,1,0])
			sliderTime = t2
			rotate WingBaseMesh (angleaxis 120 [0,1,0])
			)
			setAfterORT  WingBaseMesh.rotation.controller.Y_Rotation.controller #loop
			setBeforeORT  WingBaseMesh.rotation.controller.Y_Rotation.controller #loop
			rotate WingTipMesh (angleaxis 45 [0,1,0])
			
			with animate on 
			(
			sliderTime = t1
			rotate WingTipMesh (angleaxis -120 [0,1,0])
			sliderTime = t2
			rotate WingTipMesh (angleaxis 120 [0,1,0])
			)
			setAfterORT  WingTipMesh.rotation.controller.Y_Rotation.controller #loop
			setBeforeORT  WingTipMesh.rotation.controller.Y_Rotation.controller #loop
			moveKeys WingTipMesh.rotation.controller.Y_Rotation.controller 3f
			rotate WingBaseMesh2 (angleaxis -45 [0,1,0])
			
			theProgressGroup.value = 70
			
			with animate on 
			(
			sliderTime = t1
			rotate WingBaseMesh2 (angleaxis 120 [0,1,0])
			sliderTime = t2
			rotate WingBaseMesh2 (angleaxis -120 [0,1,0])
			)

			setAfterORT  WingBaseMesh2.rotation.controller.Y_Rotation.controller #loop
			setBeforeORT  WingBaseMesh2.rotation.controller.Y_Rotation.controller #loop
			rotate WingTipMesh2 (angleaxis -45 [0,1,0])
			
			with animate on 
			(
			sliderTime = t1
			rotate WingTipMesh2 (angleaxis 120 [0,1,0])
			sliderTime = t2
			rotate WingTipMesh2 (angleaxis -120 [0,1,0])
			)
			setAfterORT  WingTipMesh2.rotation.controller.Y_Rotation.controller #loop
			setBeforeORT  WingTipMesh2.rotation.controller.Y_Rotation.controller #loop
			moveKeys WingTipMesh2.rotation.controller.Y_Rotation.controller 3f

			WingBaseMesh.parent = BodyMesh
			WingBaseMesh2.parent = BodyMesh
			
			theProgressGroup.value = 80

			with animate on
			(
			sliderTime = t1
			move BodyMesh [0,0,-1]
			sliderTime = t2
			move BodyMesh [0,0,1]
			)
			
			setAfterORT  BodyMesh.pos.controller.Z_Position.controller #loop
			setBeforeORT  BodyMesh.pos.controller.Z_Position.controller #loop
			moveKeys  BodyMesh.pos.controller.Z_Position.controller 3f
			
			theProgressGroup.value = 85
			
			WingBaseMesh.name = "pigeon_WingBaseMesh"
			WingBaseMesh2.name = "pigeon_WingBaseMesh2"
			WingTipMesh.name = "pigeon_WingTipMesh"
			WingTipMesh2.name = "pigeon_WingTipMesh2"
			BodyMesh.name = "pigeon_BodyMesh"
			birdGeometry = #(WingBaseMesh, WingBaseMesh2, WingTipMesh, WingTipMesh2, BodyMesh)
			pigeonGroup = group birdGeometry name:"pigeon"
			
			theProgressGroup.value = 90

			if makeParticleFlow == true then
			(
				progressLabel.text = " status: creating particles"
				
				timeVal = slidertime
				randomSeed = (random 1000 9999)
				newWind = Wind pos:[0,0,0] isSelected:on iconSize:10 strength: 0 scale: 0.05 turbulence: 0.4
				
				newPFSource = PF_Source X_Coord:20 Y_Coord:0 isSelected:on Logo_Size:20 Emitter_Length:35 Emitter_Width:35 Emitter_Height:0 pos:[0,0,0]
				rotate newPFSource (angleaxis -120 [1,0,0])
				
				undo "pf edit" on
				(			
					particleFlow.BeginEdit()
					op1 = Birth Emit_Start: 0 Emit_Stop: 2600 amount: NumberOfBirds
					op2 = Position_Icon location: 3 Random_Seed: randomSeed
					op3 = Speed speed: 250 variation: 50 divergence: 25 Random_Seed: randomSeed
					op4 = Rotation direction: 4 Euler_Z: 90
					op5 = Shape_Instance Shape_Object: pigeonGroup Object_And_Children: on Group_Members: off variation: 20 Scale_Value: 100 Animated_Shape: on Add_Random_Offset: on Random_Offset: 2000 --Acquire_Material: on
					op6 = RenderParticles()
					op7 = Force Force_Space_Warps: #(newWind)
					op8 = DisplayParticles type: 6 color:(random (color 0 0 0) (color 255 255 255))
					newPFEvent = Event()
					newPFEvent.SetPViewLocation ($.X_Coord) ($.Y_Coord+100)
					
					op5.Acquire_Material = off
					op5.Acquire_Material = on
						
					particleFlow.EndEdit()
					newPFEvent.AppendAction op1
					newPFEvent.AppendAction op2
					newPFEvent.AppendAction op3
					newPFEvent.AppendAction op4
					newPFEvent.AppendAction op5
					newPFSource.AppendAction op6
					newPFEvent.AppendAction op7
					newPFEvent.AppendAction op8
					newPFSource.AppendInitialActionList newPFEvent
					newPFSource.Enable_Particles = on
					newPFSource.Quantity_Viewport = 100
					newPFSource.Integration_for_Viewport = 1
				)
				
				theProgressGroup.value = 95
				
				holdMaxFile()
				fetchMaxFile quiet:true
				slidertime = 20f
				
			)else()
			
		theProgressGroup.value = 100
			
		clearselection()
		enablesceneredraw()
		redrawviews()
			
		timerEnd = timeStamp()
		progressLabel.text =  (" Generation took: " + (((timerEnd - timerStart) / 1000.0) as string) + " s")

	)catch
		(
		enablesceneredraw()
		redrawviews()
		)
	)

)

AddSubRollout DebrisMaker.theSubrollout birdsPigeonModule
debrisMaker.height = 296