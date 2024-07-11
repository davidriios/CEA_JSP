<%@ page errorPage="../error.jsp"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String fg = request.getParameter("fg");
int total = Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
String compania = (String) session.getAttribute("_companyId");

if (fg == null) fg = "DO";

if (request.getMethod().equalsIgnoreCase("GET"))
{
  if (fg.trim().equals("DO")) cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+compania+",'EXP_INTERV_ESCALAS_DO'),'') as color from dual");
  else cdo = SQLMgr.getData("select nvl(get_sec_comp_param("+compania+",'EXP_INTERV_ESCALAS'),'') as color from dual");
  
  if (cdo==null) cdo = new CommonDataObject();
  String _color = cdo.getColValue("color");  //0-3:green,4-6:yellow,7-10:red
  String colorClass = "";
  String level = "";
   
  try{
	String[] c1 = _color.split(","); //0-3:green
	for (int a=0;a<c1.length;a++){
	  String[] c2 = c1[a].split(":"); //0-3,green,bajo
	  String[] c3 = c2[0].split("-"); //0,3
	  int from = Integer.parseInt(c3[0]);
	  int to = Integer.parseInt(c3[1]);
	  if (total >= from && total <= to){
	    colorClass=c2[1].toLowerCase();
		level =c2[2].toLowerCase(); 
		break;
	  }
	}
	String[] c2 = _color.split(",");
  }catch(Exception e){System.out.println("::::::::::::::::::::::::::::: Error al buscar los colores de la cabecera de la intervención");e.printStackTrace();}
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_min.jsp"%>
<script>
document.title = 'ESCALAS - '+document.title;

$(function(){
	var highLight = {"bajo" : "<%=colorClass%>","medio" : "<%=colorClass%>","alto" : "<%=colorClass%>"};
	if ("<%=level%>" == "bajo") $("#low").css("background-color","<%=colorClass%>");
	else if ("<%=level%>" == "medio") $("#medium").css({"background-color":"<%=colorClass%>","color":"#000"});
	else if ("<%=level%>" == "alto") $("#high").css("background-color","<%=colorClass%>");
});
</script>
<style>
  .va{vertical-align:top; font-size:14px}
  <%if(!fg.trim().equals("DO")){%>
  ul{list-style-type: none;}
  <%}%>
  li{padding-bottom:5px}
  .highlight{background-color:<%=colorClass%>;color:#000;font-style:bold;}
</style>
</head>
<body topmargin="0" leftmargin="0">

<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>

			<table width="100%" cellpadding="1" cellspacing="1">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("fg",""+fg)%>
				
				<%if(!fg.trim().equalsIgnoreCase("DO")){%>
				<tr align="center">
					<td width="33%" id="low" class="TextHeader">ESCALA DE 0-3</td>
					<td width="34%" id="medium" class="TextHeader">ESCALA DE 4-6</td>
					<td width="33%" id="high" class="TextHeader">ESCALA DE 7-10</td>
				</tr>
				<tr class="TextRow01">
					<td class="va">
						<ul>
							<li>1. Se ofrece asistencia en sus necesidades, apoyo y orientación.</li>
							<li>2 Se procura  comodidad y confort Posicionamiento</li>
							<li>3. Se evitara esfuerzos innecesarios.</li>
							<li>4. Se coloca almohadas sobre el área adolorida si fuese necesario.</li>
							<li>5. Se Orienta  sobre ejercicios de relajación.</li>
							<li>6. Masaje dorsal si fuese necesario.</li>
							<li>7. Se Administra medicamentos analgésicos indicados.</li>
							<li>8. Reevaluación a los 30 minutos si es medicamentos IV, IM, SC Y 45 minutos si son orales  y tópicos.</li>
							<li>9. Compresas frías/calientes</li>
						<ul>
					</td>
					<td class="va">
						<ul>
							<li>1. Ofrece los cuidados de la escala del 0 al 3.</li>
							<li>2. Aplicar medicamentos para el dolor PRN indicados.</li>
							<li>3. Reevaluación a los 30 minutos si es medicamentos IV, IM, SC Y 45 minutos si son orales  y tópicos.</li>
							<li>4. Procurar un ambiente tranquilo.</li>
						<ul>
					</td>
					<td class="va">
						<ul>
							<li>1. Aplicar medicamentos para el dolor PRN indicados.</li>
							<li>2. Reevaluación a los 30 minutos si es medicamentos IV, IM, SC Y 45 minutos si son orales  y tópicos.</li>
							<li>3. Llamar al médico Hospitalista y/o su médico tratante.</li>
						</ul>
					</td>
				</tr>
				<%}else{%>
				  <tr align="center">
					<td width="50%" id="low" class="TextHeader">0-2 (Bajo Riesgo)</td>
					<td width="50%" id="high" class="TextHeader">Mayor De 2 (Alto Riesgo)</td>
				</tr>
				
				<tr class="TextRow01">
					<td class="va">
						<ol>
							<li><strong>Medidas preventivas generales:</strong>
								<ul>
									<li>Realizar evaluación de caída a todos los pacientes ambulatorios y hospitalizados. Al detectar el Riesgo de caída Colocar señales que alerten al personal  (rotulo en la puerta de RIESGO BAJO).</li>
									<li>Orientación sobre prevención de caídas y entrega de información y folletos de orientación </li>
									<li>Colocar los objetos al alcance del paciente</li>
									<li>Utilizar barandales altos, Colocar la cama en la posición más baja</li>
									<li>Proporcionar al paciente dependiente medios de solicitud de ayuda (timbre) cuando el cuidador esté ausente</li>
									<li>Responder al timbre y luz de llamada inmediatamente.</li>
									<li>Mantener los dispositivos de ayuda en buen estado.</li>
								</ul>
							</li>
							
							<li><strong>Manejo del entorno:</strong>
								<ul>
									<li>Bloquear las ruedas de las sillas, camas u otros dispositivos.</li>
									<li>Disponer sillas de altura adecuada, con respaldo y apoyabrazos.</li>
									<li>Utilizar la técnica adecuada para colocar y levantar al paciente de la silla de ruedas, cama, baño, etc. (camillas…)</li>
									<li>Educar a los miembros de la familia sobre los factores de riesgo que contribuyen a las caídas y cómo disminuirlos.</li>
								</ul>
							</li>
							
							<li><strong>Corregir los factores de riesgo si son corregibles:</strong>
								<ul>
									<li><strong>Riesgos ambientales generales.</strong> Iluminación inadecuada, suelos resbaladizos, superficies irregulares, barreras arquitectónicas. Espacios reducidos, mobiliario inadecuado.</li>
									<li><strong>Riesgos del entorno: unidad asistencial.</strong> Altura de las camillas/camas y ausencia de dispositivos  de anclaje, altura y tamaño de las barandillas, espacios reducidos, dispositivos y mobiliario que se comportan como obstáculos, ausencia y   mal funcionamiento de dispositivos de apoyo.</li>
									<li><strong>Riesgo del entorno: paciente.</strong> Calzado o ropa inadecuada, carencia inadecuada de ayudas técnicas para caminar  o desplazarse.</li>
									<li>Riesgo del entorno: evacuación / transferencia. Vía y medio de evacuación, inmovilización, formación de los profesionales, efectos del  transporte sobre la persona / proceso de salud / enfermedad.</li>
									<li><strong>Factor de tipo social.</strong> Ausencia y capacitación de red de apoyo: Cuidador / Agente de autonomía asistida.</li>
								</ul>
							</li>
							
							<li><strong>Enseñanza del proceso/enfermedad:</strong></li>
							
						</ol>
					</td>
					
					<td class="va">
						<ol>
							<li><strong>Iguales medidas preventivas generales</strong>
								<ul>
									<li>Al detectar el <strong>Riesgo de caída</strong> Colocar señales que alerten al personal  (rotulo en la puerta de <strong>RIESGO ALTO</strong>).</li>
								</ul>
							</li>
							
							<li><strong>Intervenciones especificas según el riesgo:</strong>
								<ul>
									<li><strong>Factores propios del paciente.</strong> Revisar historias de caídas con el paciente y la familia,  déficit cognitivos o físicos Controlar la marcha, el equilibrio y el cansancio en la deambulación, Ayudar a la deambulación de la persona inestable, Ayuda al autocuidado, Entrenamiento del hábito urinario, Estimulación cognitiva, Orientación de la realidad, Actuación ante la demencia, Manejo de la conducta, Fomento de la comunicación verbal/auditiva.</li>
									<li><strong>Factores ambientales</strong> Manejo ambiental: Seguridad: Rondas cada hora o cada 2 horas</li>
									<li><strong>Factores propios de la enfermedad. </strong>Manejo del dolor, Terapia ejercicio deambulación, de control muscular, de  movilidad articular, de  equilibrio,  Enseñanza habilidad psicomotora, Actuación ante la sensibilidad periférica alterada, Manejo de la  energía. Establecer un programa de ejercicios físicos de rutina que incluya el andar, Determinar con el paciente / cuidador los objetivos de los cuidados, Explorar con el paciente / cuidador las mejores formas de conseguir los objetivos,  a desarrollar un plan para cumplir con los objetivos.</li>
									
									<li><strong>Factores derivados del régimen terapéutico</strong> Enseñar al paciente / cuidador utilizar un bastón, un andador, muletas, Colaborar con otros miembros del equipo de cuidados sanitarios para minimizar los efectos secundaros, Manejo de la medicación.</li>
									<li><strong>Factores derivados de la respuesta del paciente frente a la enfermedad.</strong> Instruir al paciente / cuidador para que pida ayuda al moverse, si lo precisa, Ayudar al paciente / cuidador a identificar las practicas sobre la salud que desee cambiar.</li>
									<li><strong>Riesgos del entorno: evacuación/transferencia.</strong> Ayuda con los autocuidados: transferencia, Transporte, Derivación, Vigilancia: seguridad.</li>
									<li><strong>Factores de tipo social</strong>  Fomento la implicación familiar, Apoyo al cuidador principal.</li>
								</ul>
							</li>	
							
						    <li><strong>implementación de medidas especiales como restricción y medicamentos debe estar con una orden médica.</strong></li>
	
						</ol>
					</td>
				</tr>
				
				<%}%>
								
				<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
%>