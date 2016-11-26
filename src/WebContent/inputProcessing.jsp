
<%@page import="weka.core.neighboursearch.PerformanceStats"%>
<%@page import="java.io.FileWriter"%>
<%@page import="java.io.BufferedWriter"%>
<%@page import="java.io.File"%>
<%@page import="core.*"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import = "java.util.Collections" %>
<%@ page import="java.util.concurrent.ExecutorService"%>
<%@ page import="java.util.concurrent.Executors"%>
<%@ page import="java.util.concurrent.TimeUnit"%>

<%@page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Result Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript">
google.charts.load("current", {packages:["corechart","bar"]});
</script>
<link rel="stylesheet" type="text/css" href="jqcloud.css" >
<script type="text/javascript" src="jquery-2.2.2.min.js"></script>
<script type="text/javascript" src="jqcloud.js"></script>
</head>
<body>
		<script type="text/javascript">
		//Function for Graphs.
		function drawGraph(aspectList){
			var data = new google.visualization.arrayToDataTable(aspectList);
	        var options = {
	                width: 900,
	                chart: {
	                  title: 'Aspects Score',
	                }
	              };

	            var chart = new google.charts.Bar(document.getElementById('xy'));
	            chart.draw(data, options);			
		}
		
		//Function for Tag Clouds.
    	 function removeDuplicates(x){   	
	    	 for(var i = 0; i < x.length; i++) {
	  			  for(var j = i + 1; j < x.length; ) {
			        if(x[i].text == x[j].text)
			          {  // Found the same. Remove it.
			            x.splice(j, 1);}
			        else
			         {   // No match. Go ahead.
			            j++;}
			    }    
			}
	    	 
	     }
	     </script>
	     

	<%
	
		ScoreCalculator sc = new ScoreCalculator("F:\\eclipse-jee-luna-SR2-win32-x86_64\\serverLocation\\wtpwebapps\\Final\\SentiWordNet_3.0.0_20130122.txt");
	
		String location = "F:\\eclipse-jee-luna-SR2-win32-x86_64\\serverLocation\\wtpwebapps\\Final\\";
		String category = request.getParameter("category");
		//out.print(category);

		String reviews = request.getParameter("reviews");
		//out.print(reviews);

		String specialAspect = request.getParameter("aspects");
		//out.print(specialAspect);	

		File file = new File(location + "trial.txt");
		file.createNewFile();

		BufferedWriter bw = new BufferedWriter(new FileWriter(
				file.getAbsoluteFile()));
		bw.write(reviews);
		bw.close();

		ArrayList<Aspect> aspects = new ArrayList<Aspect>();
		//Code for Pie Chart
		int countPos=0, countNeg=0;

		//special aspect checking

		//if (category.equals("other")) {
		String[] newAspects = null;
		if (specialAspect != "" && specialAspect != null) {
			newAspects = specialAspect.split("\\s+"); 

			for (String aspect : newAspects)
				aspects.add(new Aspect(aspect));

		}
		ArrayList<Aspect> otherAspect = new ArrayList<Aspect>();
		//}
		//*********************************************************************************************************
		if (category.equals("other")) {
			for (Aspect aspect : aspects)
				otherAspect.add(aspect);

			Preprocess preprocess = new Preprocess(location + "trial.txt",
					location + "preprocessedFile");

			Aspect.setReviewFile(location + "opinionatedReviews");

			preprocess.finalPreprocess(location + "preprocessedFile",
					location + "opinionatedReviews", aspects);

			ExecutorService pool = Executors.newFixedThreadPool(8);

			for (int i = 0; i < aspects.size(); i++) {
				pool.submit(aspects.get(i));
			}

			pool.shutdown();
			pool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);%>
			
			<!-- Code for Graph -->
			 <script type="text/javascript">
     		google.charts.setOnLoadCallback(drawStuff);
     
    		 function drawStuff() {
		    	  
	    	  var arr = [];
	    	  arr.push(['Aspects', 'Score']);
	    	  
	    	  <% for (Aspect aspect1 : otherAspect) { %>
	    	  arr.push(['<%= aspect1.getAspectName() %>',<%= aspect1.getScore() %>]); 
	    	  <% } %>
				
	    	  drawGraph(arr);
		          };
			</script>
			
			<!-- Graph being displayed -->    
        	<center>
        		<div id="xy" style="width: 900px; height: 500px;"></div>
        	</center>
        	<hr>
			
			<%int no=1;
			//printing about specialized aspects
			for (Aspect aspect : otherAspect) {
				if (!Double.isNaN(aspect.getScore())) {
					out.println("<BR>");
					out.println(aspect.getAspectName() + " - "
							+ aspect.getScore());
					out.println("<BR>");
					out.print(aspect.getOpinionWords());
					out.println("<hr>");
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word:aspect.getOpinionWords() ){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}%>
					<!-- Code for Pie Chart -->
					<script type="text/javascript">
				      google.charts.setOnLoadCallback(drawChart);
				      function drawChart() {
				        var data = google.visualization.arrayToDataTable([
				          ['Opinion Type', 'Number of Words'],
				          ['Good',  <%=countPos%>],
				          ['Bad',  <%=countNeg%>]
				        ]);
				
				        var options = {
				          title: 'Opinion Words Distribution',
				          is3D: true,
				        };
				
				        var chart = new google.visualization.PieChart(document.getElementById('piechartOther'+<%=no%>));
				        chart.draw(data, options);
				      }
				    </script>
				    <%
	    			out.println("<div id=\"piechartOther"+ no +"\" style=\"width: 900px; height: 500px;\"></div>");
				    no++;
			}%>
			
			
		<% 	}
			//********************************************************************************************************
		} else if (category.equals("movie")) {
			//out.print("IN MOVIE");

			Preprocess preprocess = new Preprocess(location + "trial.txt",
					location + "preprocessedFile");

			//HARD CODED CASE---->CREATE ASPECTS HERE
			String script = "script movie screenplay story film plot writing dialogue dialogues";
			double scriptScore = 0.0;
			ArrayList<String> scriptOw = new ArrayList<String>();
			int scriptCount = 0;
			aspects.add(new Aspect("script"));
			aspects.add(new Aspect("movie"));
			aspects.add(new Aspect("screenplay"));
			aspects.add(new Aspect("story"));
			aspects.add(new Aspect("film"));
			aspects.add(new Aspect("plot"));
			aspects.add(new Aspect("writing"));
			aspects.add(new Aspect("dialogue"));
			aspects.add(new Aspect("dialogues"));

			String direction = "direction director cinematography experience cinematographer editing";
			double directionScore = 0.0;
			ArrayList<String> directionOw = new ArrayList<String>();
			int directionCount = 0;
			aspects.add(new Aspect("direction"));
			aspects.add(new Aspect("director"));
			aspects.add(new Aspect("cinematography"));
			aspects.add(new Aspect("experience"));
			aspects.add(new Aspect("cinematographer"));
			aspects.add(new Aspect("editing"));

			String performance = "performance performances actor actors actress character characters acting";
			double performanceScore = 0.0;
			int performanceCount = 0;
			ArrayList<String> performanceOw = new ArrayList<String>();
			aspects.add(new Aspect("performance"));
			aspects.add(new Aspect("performances"));
			aspects.add(new Aspect("actor"));
			aspects.add(new Aspect("actors"));
			aspects.add(new Aspect("actress"));
			aspects.add(new Aspect("character"));
			aspects.add(new Aspect("characters"));
			aspects.add(new Aspect("acting"));

			String visuals = "visuals effects visual";
			double visualScore = 0.0;
			int visualCount = 0;
			ArrayList<String> visualOw = new ArrayList<String>();
			aspects.add(new Aspect("visuals"));
			aspects.add(new Aspect("effects"));
			aspects.add(new Aspect("visual"));

			String soundtrack = "soundtrack sound score music background";
			double soundtrackScore = 0.0;
			ArrayList<String> soundtrackOw = new ArrayList<String>();
			int soundtrackCount = 0;
			aspects.add(new Aspect("soundtrack"));
			aspects.add(new Aspect("sound"));
			aspects.add(new Aspect("score"));
			aspects.add(new Aspect("music"));
			aspects.add(new Aspect("background"));

			Aspect.setReviewFile(location + "opinionatedReviews");

			preprocess.finalPreprocess(location + "preprocessedFile",
					location + "opinionatedReviews", aspects);

			ExecutorService pool = Executors.newFixedThreadPool(8);

			for (int i = 0; i < aspects.size(); i++) {
				pool.submit(aspects.get(i));
			}

			pool.shutdown();
			pool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);

			for (Aspect aspect : aspects) {
				if (!Double.isNaN(aspect.getScore())) {
					if (script.contains(aspect.getAspectName())) {
						scriptScore += aspect.getTotal();
						scriptOw.addAll(aspect.getOpinionWords());
						scriptCount += aspect.getOpinionWords().size();

					} else if (direction.contains(aspect.getAspectName())) {
						directionScore += aspect.getTotal();
						directionCount += aspect.getOpinionWords().size();
						directionOw.addAll(aspect.getOpinionWords());

					} else if (performance.contains(aspect.getAspectName())) {
						performanceScore += aspect.getTotal();
						performanceCount += aspect.getOpinionWords().size();
						performanceOw.addAll(aspect.getOpinionWords());

					} else if (visuals.contains(aspect.getAspectName())) {
						visualScore += aspect.getTotal();
						visualCount += aspect.getOpinionWords().size();
						visualOw.addAll(aspect.getOpinionWords());

					} else if (soundtrack.contains(aspect.getAspectName())) {
						soundtrackScore += aspect.getTotal();
						soundtrackCount += aspect.getOpinionWords().size();
						soundtrackOw.addAll(aspect.getOpinionWords());
					} else {
						otherAspect.add(aspect);
					}
				}
			}

			scriptScore = Math.round(scriptScore / scriptCount);
			directionScore = Math.round(directionScore / directionCount);
			performanceScore = Math.round(performanceScore
					/ performanceCount);
			visualScore = Math.round(visualScore / visualCount);
			soundtrackScore = Math.round(soundtrackScore / soundtrackCount);%>
			
			 <!-- Code for Graph -->
		    <script type="text/javascript">
		      google.charts.setOnLoadCallback(drawMovie);
		      
		      function drawMovie() {
		    	  
		    	  var arrMovie = [];
		    	  arrMovie.push(['Aspects', 'Score']);
		    	  arrMovie.push(['script' ,<%=scriptScore%>]);
		    	  arrMovie.push(['direction' ,<%=directionScore%>]);
		    	  arrMovie.push(['performance' ,<%=performanceScore%>]);
		    	  arrMovie.push(['visuals' ,<%=visualScore%>]);
		    	  arrMovie.push(['soundtrack' ,<%=soundtrackScore%>]);
		    	  
		    	  <% for (Aspect aspect : otherAspect) { %>
		    	  arrMovie.push(['<%= aspect.getAspectName() %>',<%= aspect.getScore() %>]); 
		    	  <% } %>
		    	  
		    	  drawGraph(arrMovie);
		          };
		          
			</script>
			<!-- Graph being displayed -->    
        	<center>
        		<div id="xy" style="width: 900px; height: 500px;"></div>
        	</center>
        	<hr>
        
		<%//Code for Pie Chart		
			for (String word: scriptOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
			
			out.println("<BR>");
			out.println("<h1>Script - " + scriptScore);
			out.println("<BR>");
			//out.print(scriptOw);
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		         // title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartScript'));
		        chart.draw(data, options);
		      }
		    </script>
		    
		    
			
 			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsScript =[];
		    <% for (int i=0; i<scriptOw.size(); i++) { %>
		 	 wordsScript.push({text: '<%= scriptOw.get(i) %>', weight: <%= Collections.frequency(scriptOw,scriptOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsScript); 		
			$(function(){
		          $('#cloudScript').jQCloud(wordsScript);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudScript" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartScript" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>
			<hr>	

		<%  
			//Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: directionOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
		
			out.println("<BR>");
			out.println("<h1>Graphics - " + directionScore);
			out.println("<BR>");
		//	out.print(directionOw);
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		          //title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartDirection'));
		        chart.draw(data, options);
		      }
		    </script>

			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsDirection =[];
		    <% for (int i=0; i<directionOw.size(); i++) { %>
		 	 wordsDirection.push({text: '<%= directionOw.get(i) %>', weight: <%= Collections.frequency(directionOw,directionOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsDirection); 		
			$(function(){
		          $('#cloudDirection').jQCloud(wordsDirection);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudDirection" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartDirection" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>
			<hr>
		<%  
			//Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: performanceOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}	
		
			out.println("<BR>");
			out.println("<h1>Performance - " + performanceScore);
			out.println("<BR>");
		//	out.print(performanceOw);
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		          //title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartPerformance'));
		        chart.draw(data, options);
		      }
		    </script>
			
 			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsPerformance =[];
		    <% for (int i=0; i<performanceOw.size(); i++) { %>
		 	 wordsPerformance.push({text: '<%= performanceOw.get(i) %>', weight: <%= Collections.frequency(performanceOw,performanceOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsPerformance); 		
			$(function(){
		          $('#cloudPerformance').jQCloud(wordsPerformance);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudPerformance" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartPerformance" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>	
			<hr>

		<% 	
			//Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: visualOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
			
			out.println("<BR>");
			out.println("<h1>Visuals - " + visualScore);
			out.println("<BR>");
		//	out.print(visualOw);
			 %>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		         // title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartVisual'));
		        chart.draw(data, options);
		      }
		    </script>
			
 			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsVisual =[];
		    <% for (int i=0; i<visualOw.size(); i++) { %>
		 	 wordsVisual.push({text: '<%= visualOw.get(i) %>', weight: <%= Collections.frequency(visualOw,visualOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsVisual); 		
			$(function(){
		          $('#cloudVisual').jQCloud(wordsVisual);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudVisual" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartVisual" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>	
			<hr>
						
		<%  
			//Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: soundtrackOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
		
			out.println("<BR>");
			out.println("<h1>Soundtrack - " + soundtrackScore);
			out.println("<BR>");
		//	out.print(soundtrackOw);
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		         // title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartSoundtrack'));
		        chart.draw(data, options);
		      }
		    </script>
			
			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsSoundtrack =[]; 
		    <% for (int i=0; i<soundtrackOw.size(); i++) { %>
		 	 wordsSoundtrack.push({text: '<%= soundtrackOw.get(i) %>', weight: <%= Collections.frequency(soundtrackOw,soundtrackOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsSoundtrack); 		
			$(function(){
		          $('#cloudSoundtrack').jQCloud(wordsSoundtrack);		        
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudSoundtrack" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartSoundtrack" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>	
			<hr>
			
		<% 	
			int no=1;countPos=0; countNeg=0;
			//printing about specialized aspects
			for (Aspect aspect : otherAspect) {
				out.println("<BR>");
				out.println("<h1>"+aspect.getAspectName() + " - "
						+ aspect.getScore()+"</h1>");
				out.println("<BR>");
				out.print(aspect.getOpinionWords());
				out.println("<hr>");
				//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word:aspect.getOpinionWords() ){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}%>
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
			      google.charts.setOnLoadCallback(drawChart);
			      function drawChart() {
			        var data = google.visualization.arrayToDataTable([
			          ['Opinion Type', 'Number of Words'],
			          ['Good',  <%=countPos%>],
			          ['Bad',  <%=countNeg%>]
			        ]);
			
			        var options = {
			          //title: 'Opinion Words Distribution',
			          is3D: true,
			        };
			
			        var chart = new google.visualization.PieChart(document.getElementById('piechartSpecial'+<%=no%>));
			        chart.draw(data, options);
			      }
			    </script>
			    <%
    			out.println("<div id=\"piechartSpecial"+ no +"\" style=\"width: 900px; height: 500px;\"></div>");
			    no++;
			}%>
			
		    
<%--		
			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsSpecial =[[]]; j=0;
		    <%for (Aspect aspect : otherAspect){
			    for (int i=0; i<aspect.getOpinionWords().size(); i++) { %>
			 	 wordsSpecial.push({text: '<%= aspect.getOpinionWords().get(i) %>', weight: <%= Collections.frequency(aspect.getOpinionWords(),aspect.getOpinionWords().get(i)) %>}); 		//JSON Document
	   	  	<% 	}%>
	   	 	 	removeDuplicates(wordsSpecial[j]); 
	   		 	$(function(){
		          $('#cloudSpecial').jQCloud(wordsSpecial[j]);	
				});
	   		 	//wordsSpecial=[];
	   		 	j++;
		    <%}
		    %>	  
		    </script>
			<div id="cloudSpecial" style="width: 1000px; height: 350px;"></div>		<!-- Tag Cloud Displayed -->
--%>
		   
			
	<%	}
		//********************************************************************************************************
		else if (category.equals("restaurant")) {
			Preprocess preprocess = new Preprocess(location + "trial.txt",
					location + "preprocessedFile");
			//HARD CODED CASE---->CREATE ASPECTS HERE
			String ambience = "ambience decor surrounding area seating table space place atmosphere quality impression outside inside joint experience";
			double ambienceScore = 0.0;
			ArrayList<String> ambienceOw = new ArrayList<String>();
			int ambienceCount = 0;
			aspects.add(new Aspect("ambience"));
			aspects.add(new Aspect("decor"));
			aspects.add(new Aspect("surrounding"));
			aspects.add(new Aspect("area"));
			aspects.add(new Aspect("seating"));
			aspects.add(new Aspect("table"));
			aspects.add(new Aspect("space"));
			aspects.add(new Aspect("place"));
			aspects.add(new Aspect("atmosphere"));
			aspects.add(new Aspect("quality"));
			aspects.add(new Aspect("impression"));
			aspects.add(new Aspect("outside"));
			aspects.add(new Aspect("inside"));
			aspects.add(new Aspect("joint"));
			aspects.add(new Aspect("experience"));

			String service = "service waiting serving waitressing attendance dining";
			double serviceScore = 0.0;
			ArrayList<String> serviceOw = new ArrayList<String>();
			int serviceCount = 0;
			aspects.add(new Aspect("service"));
			aspects.add(new Aspect("waiting"));
			aspects.add(new Aspect("serving"));
			aspects.add(new Aspect("waitressing"));
			aspects.add(new Aspect("attendance"));
			aspects.add(new Aspect("dining"));

			String staff = "staff waiters waiter manager";
			double staffScore = 0.0;
			ArrayList<String> staffOw = new ArrayList<String>();
			int staffCount = 0;
			aspects.add(new Aspect("staff"));
			aspects.add(new Aspect("waiters"));
			aspects.add(new Aspect("waiter"));
			aspects.add(new Aspect("manager"));

			String food = "food menu flavors variety veg non-veg starter dessert starters desserts buffet lunch dinner breakfast drinks meal dish dishes taste everything";
			double foodScore = 0.0;
			ArrayList<String> foodOw = new ArrayList<String>();
			int foodCount = 0;
			aspects.add(new Aspect("food"));
			aspects.add(new Aspect("menu"));
			aspects.add(new Aspect("flavors"));
			aspects.add(new Aspect("variety"));
			aspects.add(new Aspect("veg"));
			aspects.add(new Aspect("non-veg"));
			aspects.add(new Aspect("starter"));
			aspects.add(new Aspect("dessert"));
			aspects.add(new Aspect("starters"));
			aspects.add(new Aspect("desserts"));
			aspects.add(new Aspect("buffet"));
			aspects.add(new Aspect("lunch"));
			aspects.add(new Aspect("dinner"));
			aspects.add(new Aspect("breakfast"));
			aspects.add(new Aspect("drinks"));
			aspects.add(new Aspect("meal"));
			aspects.add(new Aspect("dish"));
			aspects.add(new Aspect("dishes"));
			aspects.add(new Aspect("taste"));
			aspects.add(new Aspect("everything"));

			String price = "price cost value money";
			double priceScore = 0.0;
			ArrayList<String> priceOw = new ArrayList<String>();
			int priceCount = 0;
			aspects.add(new Aspect("price"));
			aspects.add(new Aspect("cost"));
			aspects.add(new Aspect("value"));
			aspects.add(new Aspect("money"));

			
			Aspect.setReviewFile(location + "opinionatedReviews");

			preprocess.finalPreprocess(location + "preprocessedFile",
					location + "opinionatedReviews", aspects);

			ExecutorService pool = Executors.newFixedThreadPool(8);

			for (int i = 0; i < aspects.size(); i++) {
				pool.submit(aspects.get(i));
			}

			pool.shutdown();
			pool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
			
			for (Aspect aspect : aspects) {
				if (!Double.isNaN(aspect.getScore())) {
					if (ambience.contains(aspect.getAspectName())) {
						ambienceScore += aspect.getTotal();
						ambienceOw.addAll(aspect.getOpinionWords());
						ambienceCount += aspect.getOpinionWords().size();

					} else if (service.contains(aspect.getAspectName())) {
						serviceScore += aspect.getTotal();
						serviceCount += aspect.getOpinionWords().size();
						serviceOw.addAll(aspect.getOpinionWords());

					} else if (staff.contains(aspect.getAspectName())) {
						staffScore += aspect.getTotal();
						staffCount += aspect.getOpinionWords().size();
						staffOw.addAll(aspect.getOpinionWords());

					} else if (food.contains(aspect.getAspectName())) {
						foodScore += aspect.getTotal();
						foodCount += aspect.getOpinionWords().size();
						foodOw.addAll(aspect.getOpinionWords());

					} else if (price.contains(aspect.getAspectName())) {
						priceScore += aspect.getTotal();
						priceCount += aspect.getOpinionWords().size();
						priceOw.addAll(aspect.getOpinionWords());
					} else {
						otherAspect.add(aspect);
					}
				}
			}
			
			
			
			
			ambienceScore = Math.round(ambienceScore / ambienceCount);
			serviceScore = Math.round(serviceScore / serviceCount);
			staffScore = Math.round(staffScore
					/ staffCount);
			foodScore = Math.round(foodScore / foodCount);
			priceScore = Math.round(priceScore / priceCount);%>
			
			<!-- Code for Graph -->
		    <script type="text/javascript">
		      google.charts.setOnLoadCallback(drawRestaurant);
		      
		      function drawRestaurant() {
		    	  
		    	  var arrRest = [];
		    	  arrRest.push(['Aspects', 'Score']);
		    	  arrRest.push(['Ambience' ,<%=ambienceScore%>]);
		    	  arrRest.push(['Service' ,<%=serviceScore%>]);
		    	  arrRest.push(['Staff' ,<%=staffScore%>]);
		    	  arrRest.push(['Food' ,<%=foodScore%>]);
		    	  arrRest.push(['Price' ,<%=priceScore%>]);
		    	  
		    	  <% for (Aspect aspect : otherAspect) { %>
		    	  arrMovie.push(['<%= aspect.getAspectName() %>',<%= aspect.getScore() %>]); 
		    	  <% } %>
		    	  
		    	  drawGraph(arrRest);
		          };
		          
		</script>
			<!-- Graph being displayed -->    
		<center>
        		<div id="xy" style="width: 900px; height: 500px;"></div>
        	</center>
        	<hr>
			
		<% 	//Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: ambienceOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
			
			out.println("<BR>");
			out.println("<h1>Ambience - " + ambienceScore);
			out.println("<BR>");
			//out.print(ambienceOw);
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		          title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartAmbience'));
		        chart.draw(data, options);
		      }
		    </script>
			
			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsAmbience =[];
		    <% for (int i=0; i<ambienceOw.size(); i++) { %>
		 	 wordsAmbience.push({text: '<%= ambienceOw.get(i) %>', weight: <%= Collections.frequency(ambienceOw,ambienceOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsAmbience); 		
			$(function(){
		          $('#cloudAmbience').jQCloud(wordsAmbience);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudAmbience" style="width: 1000px; height: 350px;"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartAmbience" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>
			<hr>
					

		<%  //Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: serviceOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
			
			out.println("<BR>");
			out.println("<h1>Service - " + serviceScore);
			out.println("<BR>");
			//out.print(serviceOw);
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		          title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartService'));
		        chart.draw(data, options);
		      }
		    </script>
			
			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsService =[];
		    <% for (int i=0; i<serviceOw.size(); i++) { %>
		 	 wordsService.push({text: '<%= serviceOw.get(i) %>', weight: <%= Collections.frequency(serviceOw,serviceOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsService); 		
			$(function(){
		          $('#cloudService').jQCloud(wordsService);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudService" style="width: 1000px; height: 350px;"></div>		<!-- Tag Cloud Displayed -->	
			<td><div id="piechartService" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>
			<hr>
			

		<% 	//Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: staffOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
			out.println("<BR>");
			out.println("Staff - " + staffScore);
			out.println("<BR>");
			//out.print(staffOw);
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		          title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartStaff'));
		        chart.draw(data, options);
		      }
		    </script>
	
			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsStaff =[];
		    <% for (int i=0; i<staffOw.size(); i++) { %>
		 	 wordsStaff.push({text: '<%= staffOw.get(i) %>', weight: <%= Collections.frequency(staffOw,staffOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsStaff); 		
			$(function(){
		          $('#cloudStaff').jQCloud(wordsStaff);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudStaff" style="width: 1000px; height: 350px;"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartStaff" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>
			<hr>
				

		<%	//Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: foodOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
			
			out.println("<BR>");
			out.println("Food - " + foodScore);
			out.println("<BR>");
			//out.print(foodOw);
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		          title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartFood'));
		        chart.draw(data, options);
		      }
		    </script>

			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsFood =[];
		    <% for (int i=0; i<foodOw.size(); i++) { %>
		 	 wordsFood.push({text: '<%= foodOw.get(i) %>', weight: <%= Collections.frequency(foodOw,foodOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsFood); 		
			$(function(){
		          $('#cloudFood').jQCloud(wordsFood);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudFood" style="width: 1000px; height: 350px;"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartFood" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>
			<hr>
				

		<%	//Code for Pie Chart		
			countPos=0; countNeg=0;
			for (String word: priceOw){
				if(sc.isPositive(word))
					countPos++;
				else
					countNeg++;
			}
			
			out.println("<BR>");
			out.println("Price - " + priceScore);
			out.println("<BR>");
			//out.print(priceOw);	
			%>
			
			<!-- Code for Pie Chart -->
			<script type="text/javascript">
		      google.charts.setOnLoadCallback(drawChart);
		      function drawChart() {
		        var data = google.visualization.arrayToDataTable([
		          ['Opinion Type', 'Number of Words'],
		          ['Good',  <%=countPos%>],
		          ['Bad',  <%=countNeg%>]
		        ]);
		
		        var options = {
		          title: 'Opinion Words Distribution',
		          is3D: true,
		        };
		
		        var chart = new google.visualization.PieChart(document.getElementById('piechartPrice'));
		        chart.draw(data, options);
		      }
		    </script>

			<!-- Code for Tag Cloud -->
			<script type = "text/javascript">
			
			wordsPrice =[];
		    <% for (int i=0; i<priceOw.size(); i++) { %>
		 	 wordsPrice.push({text: '<%= priceOw.get(i) %>', weight: <%= Collections.frequency(priceOw,priceOw.get(i)) %>}); 		//JSON Document
	   	  	<% } %>	   	  	
	   	  	removeDuplicates(wordsPrice); 		
			$(function(){
		          $('#cloudPrice').jQCloud(wordsPrice);	
			});
			
			</script>
			<table>
			<tr>
			<td><div id="cloudPrice" style="width: 1000px; height: 350px;"></div>		<!-- Tag Cloud Displayed -->
			<td><div id="piechartPrice" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
			</tr>
			</table>
			<hr>
				

		<%	int no=1;countPos=0; countNeg=0;
			//printing about specialized aspects
			for (Aspect aspect : otherAspect) {
				out.println("<BR>");
				out.println("<h1>"+aspect.getAspectName() + " - "
						+ aspect.getScore()+"</h1>");
				out.println("<BR>");
				out.print(aspect.getOpinionWords());
				out.println("<hr>");
				countPos=0; countNeg=0;
				for (String word:aspect.getOpinionWords() ){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}%>
			
			<!-- Code for Pie Chart -->
				<script type="text/javascript">
			      google.charts.setOnLoadCallback(drawChart);
			      function drawChart() {
			        var data = google.visualization.arrayToDataTable([
			          ['Opinion Type', 'Number of Words'],
			          ['Good',  <%=countPos%>],
			          ['Bad',  <%=countNeg%>]
			        ]);
			
			        var options = {
			          //title: 'Opinion Words Distribution',
			          is3D: true,
			        };
			
			        var chart = new google.visualization.PieChart(document.getElementById('piechartSpecial'+<%=no%>));
			        chart.draw(data, options);
			      }
			    </script>
			    <%
    			out.println("<div id=\"piechartSpecial"+ no +"\" style=\"width: 900px; height: 500px;\"></div>");
			    no++;
			}
		}
		//********************************************************************************************************
				else if (category.equals("smartphone")) {
					//out.println("In smartphone");

					Preprocess preprocess = new Preprocess(location + "trial.txt",
							location + "preprocessedFile");
					//HARD CODED CASE---->CREATE ASPECTS HERE
					String body = "body weight sim dimensions design cover build quality back size phone feel look looks";
					double bodyScore = 0.0;
					ArrayList<String> bodyOw = new ArrayList<String>();
					int bodyCount = 0;
					aspects.add(new Aspect("body"));
					aspects.add(new Aspect("weight"));
					aspects.add(new Aspect("sim"));
					aspects.add(new Aspect("dimensions"));
					aspects.add(new Aspect("design"));
					aspects.add(new Aspect("cover"));
					aspects.add(new Aspect("build"));
					aspects.add(new Aspect("quality"));
					aspects.add(new Aspect("back"));
					aspects.add(new Aspect("size"));
					aspects.add(new Aspect("phone"));
					aspects.add(new Aspect("feel"));
					aspects.add(new Aspect("look"));
					aspects.add(new Aspect("looks"));

					String display = "display resolution multitouch screen brightness touch glass protection colors pixels";
					double displayScore = 0.0;
					ArrayList<String> displayOw = new ArrayList<String>();
					int displayCount = 0;
					aspects.add(new Aspect("display"));
					aspects.add(new Aspect("resolution"));
					aspects.add(new Aspect("multitouch"));
					aspects.add(new Aspect("screen"));
					aspects.add(new Aspect("brightness"));
					aspects.add(new Aspect("touch"));
					aspects.add(new Aspect("glass"));
					aspects.add(new Aspect("protection"));
					aspects.add(new Aspect("colors"));
					aspects.add(new Aspect("pixels"));

					String processor = "processor os chipset cpu gpu speed rate performance quality android";
					double processorScore = 0.0;
					ArrayList<String> processorOw = new ArrayList<String>();
					int processorCount = 0;
					aspects.add(new Aspect("processor"));
					aspects.add(new Aspect("os"));
					aspects.add(new Aspect("chipset"));
					aspects.add(new Aspect("cpu"));
					aspects.add(new Aspect("gpu"));
					aspects.add(new Aspect("speed"));
					aspects.add(new Aspect("rate"));
					aspects.add(new Aspect("performance"));
					aspects.add(new Aspect("quality"));
					aspects.add(new Aspect("android"));

					String memory = "memory ram ddr3";
					double memoryScore = 0.0;
					ArrayList<String> memoryOw = new ArrayList<String>();
					int memoryCount = 0;
					aspects.add(new Aspect("memory"));
					aspects.add(new Aspect("ram"));
					aspects.add(new Aspect("ddr3"));

					String storage = "storage space sd internal external slot microsd";
					double storageScore = 0.0;
					ArrayList<String> storageOw = new ArrayList<String>();
					int storageCount = 0;
					aspects.add(new Aspect("storage"));
					aspects.add(new Aspect("space"));
					aspects.add(new Aspect("sd"));
					aspects.add(new Aspect("internal"));
					aspects.add(new Aspect("external"));
					aspects.add(new Aspect("slot"));
					aspects.add(new Aspect("microsd"));

					String camera = "camera primary secondary front rear features video mp";
					double cameraScore = 0.0;
					ArrayList<String> cameraOw = new ArrayList<String>();
					int cameraCount = 0;
					aspects.add(new Aspect("camera"));
					aspects.add(new Aspect("primary"));
					aspects.add(new Aspect("secondary"));
					aspects.add(new Aspect("front"));
					aspects.add(new Aspect("rear"));
					aspects.add(new Aspect("features"));
					aspects.add(new Aspect("video"));
					aspects.add(new Aspect("mp"));

					String sound = "sound alert loudspeaker speaker song audio";
					double soundScore = 0.0;
					ArrayList<String> soundOw = new ArrayList<String>();
					int soundCount = 0;
					aspects.add(new Aspect("sound"));
					aspects.add(new Aspect("alert"));
					aspects.add(new Aspect("loudspeaker"));
					aspects.add(new Aspect("speaker"));
					aspects.add(new Aspect("song"));
					aspects.add(new Aspect("audio"));

					String battery = "battery stand-by talk time usage cell backup";
					double batteryScore = 0.0;
					ArrayList<String> batteryOw = new ArrayList<String>();
					int batteryCount = 0;
					aspects.add(new Aspect("battery"));
					aspects.add(new Aspect("stand-by"));
					aspects.add(new Aspect("talk"));
					aspects.add(new Aspect("time"));
					aspects.add(new Aspect("usage"));
					aspects.add(new Aspect("cell"));
					aspects.add(new Aspect("backup"));

					Aspect.setReviewFile(location + "opinionatedReviews");

					preprocess.finalPreprocess(location + "preprocessedFile",
							location + "opinionatedReviews", aspects);

					ExecutorService pool = Executors.newFixedThreadPool(8);

					for (int i = 0; i < aspects.size(); i++) {
						pool.submit(aspects.get(i));
					}

					pool.shutdown();
					pool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);

					for (Aspect aspect : aspects) {
						if (!Double.isNaN(aspect.getScore())) {
							if (body.contains(aspect.getAspectName())) {
								bodyScore += aspect.getTotal();
								bodyOw.addAll(aspect.getOpinionWords());
								bodyCount += aspect.getOpinionWords().size();

							} else if (display.contains(aspect.getAspectName())) {
								displayScore += aspect.getTotal();
								displayCount += aspect.getOpinionWords().size();
								displayOw.addAll(aspect.getOpinionWords());

							} else if (processor.contains(aspect.getAspectName())) {
								processorScore += aspect.getTotal();
								processorCount += aspect.getOpinionWords().size();
								processorOw.addAll(aspect.getOpinionWords());

							} else if (memory.contains(aspect.getAspectName())) {
								memoryScore += aspect.getTotal();
								memoryCount += aspect.getOpinionWords().size();
								memoryOw.addAll(aspect.getOpinionWords());

							} else if (storage.contains(aspect.getAspectName())) {
								storageScore += aspect.getTotal();
								storageCount += aspect.getOpinionWords().size();
								storageOw.addAll(aspect.getOpinionWords());
								
							} else if (camera.contains(aspect.getAspectName())) {
								cameraScore += aspect.getTotal();
								cameraCount += aspect.getOpinionWords().size();
								cameraOw.addAll(aspect.getOpinionWords());
								
							} else if (sound.contains(aspect.getAspectName())) {
								soundScore += aspect.getTotal();
								soundCount += aspect.getOpinionWords().size();
								soundOw.addAll(aspect.getOpinionWords());
								
							} else if (battery.contains(aspect.getAspectName())) {
								batteryScore += aspect.getTotal();
								batteryCount += aspect.getOpinionWords().size();
								batteryOw.addAll(aspect.getOpinionWords());
								
							} else {
								otherAspect.add(aspect);
							}
						}
					}

					bodyScore = Math.round(bodyScore / bodyCount);
					displayScore = Math.round(displayScore / displayCount);
					processorScore = Math.round(processorScore / processorCount);
					memoryScore = Math.round(memoryScore / memoryCount);
					storageScore = Math.round(storageScore / storageCount);
					cameraScore = Math.round(cameraScore / cameraCount);
					soundScore = Math.round(soundScore / soundCount);
					batteryScore = Math.round(batteryScore / batteryCount);%>
					
					<!-- Code for Graph -->
		    <script type="text/javascript">
		      google.charts.setOnLoadCallback(drawMobile);
		      
		      function drawMobile() {
		    	  
		    	  var arrMobile = [];
		    	  arrMobile.push(['Aspects', 'Score']);
		    	  arrMobile.push(['Body' ,<%=bodyScore%>]);
		    	  arrMobile.push(['Display' ,<%=displayScore%>]);
		    	  arrMobile.push(['Memory' ,<%=memoryScore%>]);
		    	  arrMobile.push(['Storage' ,<%=storageScore%>]);
		    	  arrMobile.push(['Camera' ,<%=cameraScore%>]);
		    	  arrMobile.push(['Sound' ,<%=soundScore%>]);
		    	  arrMobile.push(['Battery' ,<%=batteryScore%>]);
		    	  
		    	  <% for (Aspect aspect : otherAspect) { %>
		    	  arrMobile.push(['<%= aspect.getAspectName() %>',<%= aspect.getScore() %>]); 
		    	  <% } %>

		    	  drawGraph(arrMobile);
			     };
				</script>
				<!-- Graph being displayed -->    
	        	<center>
	        		<div id="xy" style="width: 900px; height: 500px;"></div>
	        	</center>
	        	<hr>

				<%
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: bodyOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}	
				
					out.println("<BR>");
					out.println("<h1>Body - " + bodyScore);
					out.println("<BR>");
					//out.print(bodyOw);
					%>
					
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
			      google.charts.setOnLoadCallback(drawChart);
			      function drawChart() {
			        var data = google.visualization.arrayToDataTable([
			          ['Opinion Type', 'Number of Words'],
			          ['Good',  <%=countPos%>],
			          ['Bad',  <%=countNeg%>]
			        ]);
			
			        var options = {
			          title: 'Opinion Words Distribution',
			          is3D: true,
			        };
			
			        var chart = new google.visualization.PieChart(document.getElementById('piechartBody'));
			        chart.draw(data, options);
			      }
			    </script>
				
				
				<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsBody =[];
			    <% for (int i=0; i<bodyOw.size(); i++) { %>
			 	 wordsBody.push({text: '<%= bodyOw.get(i) %>', weight: <%= Collections.frequency(bodyOw,bodyOw.get(i)) %>}); 		//JSON Document
		   	  	<% } %>	   	  	
		   	  	removeDuplicates(wordsBody); 		
				$(function(){
			          $('#cloudBody').jQCloud(wordsBody);	
				});
				</script>
			
				<table>
				<tr>
				<td><div id="cloudBody" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartBody" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>

				<%	
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: displayOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}
					
					out.println("<BR>");
					out.println("<h1>Display - " + displayScore);
					out.println("<BR>");
					//out.print(displayOw);
					%>
					
					  <!-- Code for Pie Chart -->
					  <script type="text/javascript">
				      google.charts.setOnLoadCallback(drawChart);
				      function drawChart() {
				        var data = google.visualization.arrayToDataTable([
				          ['Opinion Type', 'Number of Words'],
				          ['Good',  <%=countPos%>],
				          ['Bad',  <%=countNeg%>]
				        ]);
				
				        var options = {
				          title: 'Opinion Words Distribution',
				          is3D: true,
				        };
				
				        var chart = new google.visualization.PieChart(document.getElementById('piechartDisplay'));
				        chart.draw(data, options);
				      }
				    </script>
					
					
					<!-- Code for Tag Cloud -->
					<script type = "text/javascript">
					
					wordsDisplay =[];
				    <% for (int i=0; i<displayOw.size(); i++) { %>
				 	 wordsDisplay.push({text: '<%= displayOw.get(i) %>', weight: <%= Collections.frequency(displayOw,displayOw.get(i)) %>}); 		//JSON Document
			   	  	<% } %>	   	  	
			   	  	removeDuplicates(wordsDisplay); 		
					$(function(){
				          $('#cloudDisplay').jQCloud(wordsDisplay);	
					});
					</script>
					
					<table>
					<tr>
					<td><div id="cloudDisplay" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
					<td><div id="piechartDisplay" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
					</tr>
					</table>
					<hr>

				<%
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: processorOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}
					
					out.println("<BR>");
					out.println("<h1>Processor - " + processorScore);
					out.println("<BR>");
					//out.print(processorOw);
					%>
					
					<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartProcessor'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsProcessor =[];
				<% for (int i=0; i<processorOw.size(); i++) { %>
				 wordsProcessor.push({text: '<%= processorOw.get(i) %>', weight: <%= Collections.frequency(processorOw,processorOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsProcessor); 		
				$(function(){
					  $('#cloudProcessor').jQCloud(wordsProcessor);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudProcessor" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartProcessor" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
					
				<% 
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: memoryOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}
					
					out.println("<BR>");
					out.println("<h1>Memory - " + memoryScore);
					out.println("<BR>");
					//out.print(memoryOw);
					%>
					
						<!-- Code for Pie Chart -->
					<script type="text/javascript">
					  google.charts.setOnLoadCallback(drawChart);
					  function drawChart() {
						var data = google.visualization.arrayToDataTable([
						  ['Opinion Type', 'Number of Words'],
						  ['Good',  <%=countPos%>],
						  ['Bad',  <%=countNeg%>]
						]);
				
						var options = {
						  title: 'Opinion Words Distribution',
						  is3D: true,
						};
				
						var chart = new google.visualization.PieChart(document.getElementById('piechartMemory'));
						chart.draw(data, options);
					  }
					</script>
					
					
						<!-- Code for Tag Cloud -->
					<script type = "text/javascript">
					
					wordsMemory =[];
					<% for (int i=0; i<memoryOw.size(); i++) { %>
					 wordsMemory.push({text: '<%= memoryOw.get(i) %>', weight: <%= Collections.frequency(memoryOw,memoryOw.get(i)) %>}); 		//JSON Document
					<% } %>	   	  	
					removeDuplicates(wordsMemory); 		
					$(function(){
						  $('#cloudMemory').jQCloud(wordsMemory);	
					});
					</script>
					
					<table>
					<tr>
					<td><div id="cloudMemory" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
					<td><div id="piechartMemory" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
					</tr>
					</table>
					<hr>

				<% 
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: storageOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}
					out.println("<BR>");
					out.println("<h1>Storage - " + storageScore);
					out.println("<BR>");
					//out.print(storageOw);
					%>
					
						<!-- Code for Pie Chart -->
					<script type="text/javascript">
					  google.charts.setOnLoadCallback(drawChart);
					  function drawChart() {
						var data = google.visualization.arrayToDataTable([
						  ['Opinion Type', 'Number of Words'],
						  ['Good',  <%=countPos%>],
						  ['Bad',  <%=countNeg%>]
						]);
				
						var options = {
						  title: 'Opinion Words Distribution',
						  is3D: true,
						};
				
						var chart = new google.visualization.PieChart(document.getElementById('piechartStorage'));
						chart.draw(data, options);
					  }
					</script>
					
					
						<!-- Code for Tag Cloud -->
					<script type = "text/javascript">
					
					wordsStorage =[];
					<% for (int i=0; i<storageOw.size(); i++) { %>
					 wordsStorage.push({text: '<%= storageOw.get(i) %>', weight: <%= Collections.frequency(storageOw,storageOw.get(i)) %>}); 		//JSON Document
					<% } %>	   	  	
					removeDuplicates(wordsStorage); 		
					$(function(){
						  $('#cloudStorage').jQCloud(wordsStorage);	
					});
					</script>
					
					<table>
					<tr>
					<td><div id="cloudStorage" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
					<td><div id="piechartStorage" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
					</tr>
					</table>
					<hr>
					
				<% 	
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: cameraOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}
				
					out.println("<BR>");
					out.println("<h1>Camera - " + cameraScore);
					out.println("<BR>");
					//out.print(cameraOw);
					%>
					
						<!-- Code for Pie Chart -->
					<script type="text/javascript">
					  google.charts.setOnLoadCallback(drawChart);
					  function drawChart() {
						var data = google.visualization.arrayToDataTable([
						  ['Opinion Type', 'Number of Words'],
						  ['Good',  <%=countPos%>],
						  ['Bad',  <%=countNeg%>]
						]);
				
						var options = {
						  title: 'Opinion Words Distribution',
						  is3D: true,
						};
				
						var chart = new google.visualization.PieChart(document.getElementById('piechartCamera'));
						chart.draw(data, options);
					  }
					</script>
					
					
						<!-- Code for Tag Cloud -->
					<script type = "text/javascript">
					
					wordsCamera =[];
					<% for (int i=0; i<cameraOw.size(); i++) { %>
					 wordsCamera.push({text: '<%= cameraOw.get(i) %>', weight: <%= Collections.frequency(cameraOw,cameraOw.get(i)) %>}); 		//JSON Document
					<% } %>	   	  	
					removeDuplicates(wordsCamera); 		
					$(function(){
						  $('#cloudCamera').jQCloud(wordsCamera);	
					});
					</script>
					
					<table>
					<tr>
					<td><div id="cloudCamera" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
					<td><div id="piechartCamera" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
					</tr>
					</table>
					<hr>
					
				<% 	
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: soundOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}
					out.println("<BR>");
					out.println("<h1>Sound - " + soundScore);
					out.println("<BR>");
					//out.print(soundOw);
					%>
					
						<!-- Code for Pie Chart -->
					<script type="text/javascript">
					  google.charts.setOnLoadCallback(drawChart);
					  function drawChart() {
						var data = google.visualization.arrayToDataTable([
						  ['Opinion Type', 'Number of Words'],
						  ['Good',  <%=countPos%>],
						  ['Bad',  <%=countNeg%>]
						]);
				
						var options = {
						  title: 'Opinion Words Distribution',
						  is3D: true,
						};
				
						var chart = new google.visualization.PieChart(document.getElementById('piechartSound'));
						chart.draw(data, options);
					  }
					</script>
					
					
						<!-- Code for Tag Cloud -->
					<script type = "text/javascript">
					
					wordsSound =[];
					<% for (int i=0; i<soundOw.size(); i++) { %>
					 wordsSound.push({text: '<%= soundOw.get(i) %>', weight: <%= Collections.frequency(soundOw,soundOw.get(i)) %>}); 		//JSON Document
					<% } %>	   	  	
					removeDuplicates(wordsSound); 		
					$(function(){
						  $('#cloudSound').jQCloud(wordsSound);	
					});
					</script>
					
					<table>
					<tr>
					<td><div id="cloudSound" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
					<td><div id="piechartSound" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
					</tr>
					</table>
					<hr>
						
				<% 	
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: batteryOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}
					out.println("<BR>");
					out.println("<h1>Battery - " + batteryScore);
					out.println("<BR>");
					//out.print(batteryOw);
					%>
					
						<!-- Code for Pie Chart -->
					<script type="text/javascript">
					  google.charts.setOnLoadCallback(drawChart);
					  function drawChart() {
						var data = google.visualization.arrayToDataTable([
						  ['Opinion Type', 'Number of Words'],
						  ['Good',  <%=countPos%>],
						  ['Bad',  <%=countNeg%>]
						]);
				
						var options = {
						  title: 'Opinion Words Distribution',
						  is3D: true,
						};
				
						var chart = new google.visualization.PieChart(document.getElementById('piechartBattery'));
						chart.draw(data, options);
					  }
					</script>
					
					
						<!-- Code for Tag Cloud -->
					<script type = "text/javascript">
					
					wordsBattery =[];
					<% for (int i=0; i<batteryOw.size(); i++) { %>
					 wordsBattery.push({text: '<%= batteryOw.get(i) %>', weight: <%= Collections.frequency(batteryOw,batteryOw.get(i)) %>}); 		//JSON Document
					<% } %>	   	  	
					removeDuplicates(wordsBattery); 		
					$(function(){
						  $('#cloudBattery').jQCloud(wordsBattery);	
					});
					</script>
					
					<table>
					<tr>
					<td><div id="cloudBattery" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
					<td><div id="piechartBattery" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
					</tr>
					</table>
					<hr>

					<% //printing about specialized aspects
					int no=1;countPos=0; countNeg=0;
					for (Aspect aspect : otherAspect) {
						out.println("<BR>");
						out.println("<h1>"+aspect.getAspectName() + " - "
								+ aspect.getScore()+"</h1>");
						out.println("<BR>");
						out.print(aspect.getOpinionWords());
						out.println("<hr>");
						countPos=0; countNeg=0;
						for (String word:aspect.getOpinionWords() ){
							if(sc.isPositive(word))
								countPos++;
							else
								countNeg++;
						}%>
						<!-- Code for Pie Chart -->
						<script type="text/javascript">
					      google.charts.setOnLoadCallback(drawChart);
					      function drawChart() {
					        var data = google.visualization.arrayToDataTable([
					          ['Opinion Type', 'Number of Words'],
					          ['Good',  <%=countPos%>],
					          ['Bad',  <%=countNeg%>]
					        ]);
					
					        var options = {
					          //title: 'Opinion Words Distribution',
					          is3D: true,
					        };
					
					        var chart = new google.visualization.PieChart(document.getElementById('piechartSpecial'+<%=no%>));
					        chart.draw(data, options);
					      }
					    </script>
					    <%
		    			out.println("<div id=\"piechartSpecial"+ no +"\" style=\"width: 900px; height: 500px;\"></div>");
					    no++;
					}
				}
		//***********************************************************************************************************************
		
			else if (category.equals("laptop")) {
				//out.println("In laptop");
			
				Preprocess preprocess = new Preprocess(location + "trial.txt",
						location + "preprocessedFile");
				
				//HARD CODED CASE---->CREATE ASPECTS HERE
				String performance = "performance quality speed pc laptop";
				double performanceScore = 0.0;
				ArrayList<String> performanceOw = new ArrayList<String>();
				int performanceCount = 0;
				aspects.add(new Aspect("performance"));
				aspects.add(new Aspect("quality"));
				aspects.add(new Aspect("speed"));
				aspects.add(new Aspect("pc"));
				
				String storage = "storage disk space harddrive drive ssd";
				double storageScore = 0.0;
				ArrayList<String> storageOw = new ArrayList<String>();
				int storageCount = 0;
				aspects.add(new Aspect("storage"));
				aspects.add(new Aspect("disk"));
				aspects.add(new Aspect("space"));
				aspects.add(new Aspect("harddrive"));
				aspects.add(new Aspect("drive"));
				aspects.add(new Aspect("ssd"));
				
				String battery = "battery cell usage backup";
				double batteryScore = 0.0;
				ArrayList<String> batteryOw = new ArrayList<String>();
				int batteryCount = 0;
				aspects.add(new Aspect("battery"));
				aspects.add(new Aspect("cell"));
				aspects.add(new Aspect("usage"));
				aspects.add(new Aspect("backup"));
			
				String speaker = "speakers speaker sound voice audio";
				double speakerScore = 0.0;
				ArrayList<String> speakerOw = new ArrayList<String>();
				int speakerCount = 0;
				aspects.add(new Aspect("speakers"));
				aspects.add(new Aspect("speaker"));
				aspects.add(new Aspect("sound"));
				aspects.add(new Aspect("voice"));
				aspects.add(new Aspect("audio"));
				
				String price = "price cost range";
				double priceScore = 0.0;
				ArrayList<String> priceOw = new ArrayList<String>();
				int priceCount = 0;
				aspects.add(new Aspect("price"));
				aspects.add(new Aspect("cost"));
				aspects.add(new Aspect("range"));
				
				String touchpad = "touchpad pad mousepad mousepad";
				double touchpadScore = 0.0;
				ArrayList<String> touchpadOw = new ArrayList<String>();
				int touchpadCount = 0;
				aspects.add(new Aspect("touchpad"));
				aspects.add(new Aspect("pad"));
				aspects.add(new Aspect("mousepad"));
				aspects.add(new Aspect("mousepad"));
				
				
				String display = "display resolution screen brightness glass protection colors pixels";
				double displayScore = 0.0;
				ArrayList<String> displayOw = new ArrayList<String>();
				int displayCount = 0;
				aspects.add(new Aspect("display"));
				aspects.add(new Aspect("resolution"));
				aspects.add(new Aspect("screen"));
				aspects.add(new Aspect("brightness"));
				aspects.add(new Aspect("glass"));
				aspects.add(new Aspect("protection"));
				aspects.add(new Aspect("colors"));
				aspects.add(new Aspect("pixels"));
				
				String graphics = "graphics gpu nvidia geforce ati radeon";
				double graphicsScore = 0.0;
				ArrayList<String> graphicsOw = new ArrayList<String>();
				int graphicsCount = 0;
				aspects.add(new Aspect("graphics"));
				aspects.add(new Aspect("gpu"));
				aspects.add(new Aspect("nvidia"));
				aspects.add(new Aspect("geforce"));
				aspects.add(new Aspect("ati"));
				aspects.add(new Aspect("radeon"));
				
				String build = "body weight dimensions design build quality back size feel look looks keyboard";
				double buildScore = 0.0;
				ArrayList<String> buildOw = new ArrayList<String>();
				int buildCount = 0;
				aspects.add(new Aspect("body"));
				aspects.add(new Aspect("weight"));
				aspects.add(new Aspect("keyboard"));
				aspects.add(new Aspect("dimensions"));
				aspects.add(new Aspect("design"));
				aspects.add(new Aspect("build"));
				aspects.add(new Aspect("quality"));
				aspects.add(new Aspect("back"));
				aspects.add(new Aspect("size"));
				aspects.add(new Aspect("feel"));
				aspects.add(new Aspect("look"));
				aspects.add(new Aspect("looks"));
				
				Aspect.setReviewFile(location + "opinionatedReviews");
			
				preprocess.finalPreprocess(location + "preprocessedFile",
						location + "opinionatedReviews", aspects);
			
				ExecutorService pool = Executors.newFixedThreadPool(4);
			
				for (int i = 0; i < aspects.size(); i++) {
					pool.submit(aspects.get(i));
				}
			
				pool.shutdown();
				pool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS);
				
				for (Aspect aspect : aspects) {
					if (!Double.isNaN(aspect.getScore())) {
						if (performance.contains(aspect.getAspectName())) {
							performanceScore += aspect.getTotal();
							performanceOw.addAll(aspect.getOpinionWords());
							performanceCount += aspect.getOpinionWords().size();
			
						} else if (display.contains(aspect.getAspectName())) {
							displayScore += aspect.getTotal();
							displayCount += aspect.getOpinionWords().size();
							displayOw.addAll(aspect.getOpinionWords());
			
						} else if (storage.contains(aspect.getAspectName())) {
							storageScore += aspect.getTotal();
							storageCount += aspect.getOpinionWords().size();
							storageOw.addAll(aspect.getOpinionWords());
			
						} else if (battery.contains(aspect.getAspectName())) {
							batteryScore += aspect.getTotal();
							batteryCount += aspect.getOpinionWords().size();
							batteryOw.addAll(aspect.getOpinionWords());
			
						} else if (speaker.contains(aspect.getAspectName())) {
							speakerScore += aspect.getTotal();
							speakerCount += aspect.getOpinionWords().size();
							speakerOw.addAll(aspect.getOpinionWords());
							
						} else if (price.contains(aspect.getAspectName())) {
							priceScore += aspect.getTotal();
							priceCount += aspect.getOpinionWords().size();
							priceOw.addAll(aspect.getOpinionWords());
							
						} else if (graphics.contains(aspect.getAspectName())) {
							graphicsScore += aspect.getTotal();
							graphicsCount += aspect.getOpinionWords().size();
							graphicsOw.addAll(aspect.getOpinionWords());
							
						} else if (touchpad.contains(aspect.getAspectName())) {
							touchpadScore += aspect.getTotal();
							touchpadCount += aspect.getOpinionWords().size();
							touchpadOw.addAll(aspect.getOpinionWords());
							
						} else if (build.contains(aspect.getAspectName())) {
							buildScore += aspect.getTotal();
							buildCount += aspect.getOpinionWords().size();
							buildOw.addAll(aspect.getOpinionWords());
							
						}
						
						else {
							otherAspect.add(aspect);
						}
					}
				}
				//NOTE:0.0/0.0 = NaN, Math.round(NaN) =0
				performanceScore = Math.round(performanceScore / performanceCount);
				displayScore = Math.round(displayScore / displayCount);
				storageScore = Math.round(storageScore / storageCount);
				batteryScore = Math.round(batteryScore / batteryCount);
				speakerScore = Math.round(speakerScore / speakerCount);
				priceScore = Math.round(priceScore / priceCount);
				graphicsScore = Math.round(graphicsScore / graphicsCount);
				touchpadScore = Math.round(touchpadScore / touchpadCount);
				buildScore = Math.round(buildScore / buildCount);
				%>
			
		 		<!-- Code for Graph -->
			    <script type="text/javascript">
			      google.charts.setOnLoadCallback(drawLaptop);
			      
			      function drawLaptop() {
			    	  
			    	  var arrLaptop = [];
			    	  arrLaptop.push(['Aspects', 'Score']);
			    	  arrLaptop.push(['Performance' ,<%=performanceScore%>]);
			    	  arrLaptop.push(['Display' ,<%=displayScore%>]);
			    	  arrLaptop.push(['Storage' ,<%=storageScore%>]);
			    	  arrLaptop.push(['Battery' ,<%=batteryScore%>]);
			    	  arrLaptop.push(['Speaker' ,<%=speakerScore%>]);
			    	  arrLaptop.push(['Price' ,<%=priceScore%>]);
			    	  arrLaptop.push(['Graphics' ,<%=graphicsScore%>]);
			    	  arrLaptop.push(['Touchpad' ,<%=touchpadScore%>]);
			    	  arrLaptop.push(['Build' ,<%=buildScore%>]);
			    	  
			    	  <% for (Aspect aspect : otherAspect) { %>
			    	  arrLaptop.push(['<%= aspect.getAspectName() %>',<%= aspect.getScore() %>]); 
			    	  <% } %>
			
			        var data = new google.visualization.arrayToDataTable(arrLaptop);
			        var options = {
			                width: 900,
			                chart: {
			                  title: 'Aspects Score',
			                }
			           
			              };
			
			            var chart = new google.charts.Bar(document.getElementById('xy'));
			            chart.draw(data, options);
			          };
				</script>
						<!-- Graph being displayed -->    
				<center>
					<div id="xy" style="width: 900px; height: 500px;"></div>
				</center>
				<hr>
			
			
				<%
					//Code for Pie Chart		
					countPos=0; countNeg=0;
					for (String word: performanceOw){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}
			
				out.println("<BR>");
				out.println("Performance - " + performanceScore);
				out.println("<BR>");
				//out.print(performanceOw);
				%>
				
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartPerformance'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsPerformance =[];
				<% for (int i=0; i<performanceOw.size(); i++) { %>
				 wordsPerformance.push({text: '<%= performanceOw.get(i) %>', weight: <%= Collections.frequency(performanceOw,performanceOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsPerformance); 		
				$(function(){
					  $('#cloudPerformance').jQCloud(wordsPerformance);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudPerformance" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartPerformance" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
				
			
				<%
				//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word: displayOw){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}
				
				out.println("<BR>");
				out.println("Display - " + displayScore);
				out.println("<BR>");
				//out.print(displayOw);%>
				
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartDisplay'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsDisplay =[];
				<% for (int i=0; i<displayOw.size(); i++) { %>
				 wordsDisplay.push({text: '<%= displayOw.get(i) %>', weight: <%= Collections.frequency(displayOw,displayOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsDisplay); 		
				$(function(){
					  $('#cloudDisplay').jQCloud(wordsDisplay);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudDisplay" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartDisplay" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
				
				<%
				//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word: storageOw){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}
				
				out.println("<BR>");
				out.println("Storage - " + storageScore);
				out.println("<BR>");
				//out.print(storageOw);%>
				
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartStorage'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsStorage =[];
				<% for (int i=0; i<storageOw.size(); i++) { %>
				 wordsStorage.push({text: '<%= storageOw.get(i) %>', weight: <%= Collections.frequency(storageOw,storageOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsStorage); 		
				$(function(){
					  $('#cloudStorage').jQCloud(wordsStorage);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudStorage" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartStorage" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
			
				<% 
				//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word: batteryOw){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}
				
				out.println("<BR>");
				out.println("Battery - " + batteryScore);
				out.println("<BR>");
				//out.print(batteryOw);%>
				
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartBattery'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsBattery =[];
				<% for (int i=0; i<batteryOw.size(); i++) { %>
				 wordsBattery.push({text: '<%= batteryOw.get(i) %>', weight: <%= Collections.frequency(batteryOw,batteryOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsBattery); 		
				$(function(){
					  $('#cloudBattery').jQCloud(wordsBattery);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudBattery" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartBattery" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
			
				<% 
				//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word: speakerOw){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}
				
				out.println("<BR>");
				out.println("Speakers - " + speakerScore);
				out.println("<BR>");
				//out.print(speakerOw);%>
				
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartSpeaker'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsSpeaker =[];
				<% for (int i=0; i<speakerOw.size(); i++) { %>
				 wordsSpeaker.push({text: '<%= speakerOw.get(i) %>', weight: <%= Collections.frequency(speakerOw,speakerOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsSpeaker); 		
				$(function(){
					  $('#cloudSpeaker').jQCloud(wordsSpeaker);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudSpeaker" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartSpeaker" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
				
				<%
				//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word: priceOw){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}
				
				out.println("<BR>");
				out.println("Price - " + priceScore);
				out.println("<BR>");
				//out.print(priceOw);%>
			
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartPrice'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsPrice =[];
				<% for (int i=0; i<priceOw.size(); i++) { %>
				 wordsPrice.push({text: '<%= priceOw.get(i) %>', weight: <%= Collections.frequency(priceOw,priceOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsPrice); 		
				$(function(){
					  $('#cloudPrice').jQCloud(wordsPrice);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudPrice" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartPrice" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
				
				<%
				//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word: graphicsOw){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}
				
				out.println("<BR>");
				out.println("Graphics - " + graphicsScore);
				out.println("<BR>");
				//out.print(graphicsOw);%>
				
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartGraphics'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsGraphics =[];
				<% for (int i=0; i<graphicsOw.size(); i++) { %>
				 wordsGraphics.push({text: '<%= graphicsOw.get(i) %>', weight: <%= Collections.frequency(graphicsOw,graphicsOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsGraphics); 		
				$(function(){
					  $('#cloudGraphics').jQCloud(wordsGraphics);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudGraphics" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartGraphics" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
				
				<% 
				//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word: touchpadOw){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}
				
				out.println("<BR>");
				out.println("Touchpad - " + touchpadScore);
				out.println("<BR>");
				//out.print(touchpadOw);%>
				
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartTouchpad'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsTouchpad =[];
				<% for (int i=0; i<touchpadOw.size(); i++) { %>
				 wordsTouchpad.push({text: '<%= touchpadOw.get(i) %>', weight: <%= Collections.frequency(touchpadOw,touchpadOw.get(i)) %>}); 		//JSON Document
				<% } %>	   	  	
				removeDuplicates(wordsTouchpad); 		
				$(function(){
					  $('#cloudTouchpad').jQCloud(wordsTouchpad);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudTouchpad" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartTouchpad" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
								
				<%//Code for Pie Chart		
				countPos=0; countNeg=0;
				for (String word: buildOw){
					if(sc.isPositive(word))
						countPos++;
					else
						countNeg++;
				}
				
				out.println("<BR>");
				out.println("Build Quality - " + buildScore);
				out.println("<BR>");
				//out.print(buildOw);%>
				
				<!-- Code for Pie Chart -->
				<script type="text/javascript">
				  google.charts.setOnLoadCallback(drawChart);
				  function drawChart() {
					var data = google.visualization.arrayToDataTable([
					  ['Opinion Type', 'Number of Words'],
					  ['Good',  <%=countPos%>],
					  ['Bad',  <%=countNeg%>]
					]);
			
					var options = {
					  title: 'Opinion Words Distribution',
					  is3D: true,
					};
			
					var chart = new google.visualization.PieChart(document.getElementById('piechartBuild'));
					chart.draw(data, options);
				  }
				</script>
				
				
					<!-- Code for Tag Cloud -->
				<script type = "text/javascript">
				
				wordsBuild =[];
				<% for (int i=0; i<buildOw.size(); i++) { %>
				 wordsBuild.push({text: '<%= buildOw.get(i) %>', weight: <%= Collections.frequency(buildOw,buildOw.get(i)) %>}); 		//JSON Document
				<%} %>	   	  	
				removeDuplicates(wordsBuild); 		
				$(function(){
					  $('#cloudBuild').jQCloud(wordsBuild);	
				});
				</script>
				
				<table>
				<tr>
				<td><div id="cloudBuild" style="width: 1000px; height: 350px"></div>		<!-- Tag Cloud Displayed -->
				<td><div id="piechartBuild" style="width: 700px; height: 500px;"></div>		<!-- Pie Chart Displayed -->
				</tr>
				</table>
				<hr>
			
				<%	int no=1;countPos=0; countNeg=0;
				//printing about specialized aspects
				for (Aspect aspect : otherAspect) {
					out.println("<BR>");
					out.println("<h1>"+aspect.getAspectName() + " - "
							+ aspect.getScore()+"</h1>");
					out.println("<BR>");
					//out.print(aspect.getOpinionWords());
					out.println("<hr>");
					countPos=0; countNeg=0;
					for (String word:aspect.getOpinionWords() ){
						if(sc.isPositive(word))
							countPos++;
						else
							countNeg++;
					}%>
				
				<!-- Code for Pie Chart -->
					<script type="text/javascript">
				      google.charts.setOnLoadCallback(drawChart);
				      function drawChart() {
				        var data = google.visualization.arrayToDataTable([
				          ['Opinion Type', 'Number of Words'],
				          ['Good',  <%=countPos%>],
				          ['Bad',  <%=countNeg%>]
				        ]);
				
				        var options = {
				          //title: 'Opinion Words Distribution',
				          is3D: true,
				        };
				
				        var chart = new google.visualization.PieChart(document.getElementById('piechartSpecial'+<%=no%>));
				        chart.draw(data, options);
				      }
				    </script>
				    <%
	    			out.println("<div id=\"piechartSpecial"+ no +"\" style=\"width: 900px; height: 500px;\"></div>");
				    no++;
				}
			}
	%>
</body>
</html>