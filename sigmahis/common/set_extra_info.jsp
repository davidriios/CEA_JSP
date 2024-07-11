<% response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); %>
<%//@ page trimDirectiveWhitespaces="true" %>
<%@page contentType="text/html" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
  String fp = request.getParameter("fp")==null?"":request.getParameter("fp");
  String pacId = request.getParameter("pacId")==null?"":request.getParameter("pacId");
  String noAdmision = request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision");
  String status = request.getParameter("status")==null?"":request.getParameter("status");
  String facturadoA = request.getParameter("facturadoA")==null?"":request.getParameter("facturadoA");
  String mode = request.getParameter("mode")==null?"":request.getParameter("mode");
  String admCat = request.getParameter("admCat")==null?"0":request.getParameter("admCat");
  String cds = request.getParameter("cds")==null?"0":request.getParameter("cds");
  String compania = request.getParameter("compania");

  SQLMgr.setConnection(ConMgr);
  
  StringBuffer sb = new StringBuffer();
  
  sb.append("select 'PAC' tipo, substr(nvl(a.deseo,'N/A'),1,200) deseo, substr(nvl(a.preferencia,'N/A'),1,200) preferencia,decode (a.nh,'S', 'en el hospital',null, 'Otro lado')nh, decode(a.vip,'S','VIP','D','DISTINGUIDO','M','MÉDICO STAFF','J','J.DIRECTIVA','NORMAL') fidelizacion, nvl(c.descripcion,'N/A') as religion, decode(g.descripcion,'SELECCIONE','N/A',g.descripcion) as comida, nvl(h.descripcion,'N/A') as idioma ,decode(trunc(sysdate)-7,to_date(to_char(nvl(f_nac,fecha_nacimiento),'dd/mm'),'dd/mm'),'Cumplió la semana pasada',' ') last_week,decode(trunc(sysdate)+30,to_date(to_char(nvl(f_nac,fecha_nacimiento),'dd/mm'),'dd/mm'),'Cumple el próx. mes',' ') next_month, null  fecha_preadmision, null fecha_ingreso, null categoriadesc, null centroserviciodesc, null tot, 0 cant, null nombreplan, null nombreconvenio, null nombreempresa ,case when extract(year from numtoyminterval(months_between(trunc(sysdate),nvl(f_nac,fecha_nacimiento)),'month')) >=50 and a.sexo = 'F' then 'JUBILADA' when extract(year from numtoyminterval(months_between(trunc(sysdate),nvl(f_nac,fecha_nacimiento)),'month')) >=60 and a.sexo = 'M' then 'JUBILADO' else '-' end jubilado, a.vip "); 
  
  if (mode.trim().equals("edit") || mode.trim().equals("view")){
    sb.append(" ,(select decode(condicion_paciente,'S','RIESGO DE CAIDA','NO HAY RIESGO') from tbl_adm_admision where pac_id = ");sb.append(pacId);
	sb.append(" and secuencia = ");sb.append(noAdmision);
	sb.append(") condicion ");
	sb.append(" ,(select nvl(observ_adm,'N/A') from tbl_adm_admision where pac_id = ");sb.append(pacId);
	sb.append(" and secuencia = ");sb.append(noAdmision);
	sb.append(") obserAdm ");
  }else{
    sb.append(" ,'N/A' condicion, ' ' obserAdm ");
  }
  sb.append(" from tbl_adm_paciente a,tbl_adm_religion c,tbl_adm_comida g,tbl_adm_lenguaje h where  a.religion = c.codigo(+) and a.lenguaje_id = h.lenguaje_id(+) and a.comida_id = g.comida_id(+) and a.pac_id = "); sb.append(pacId);
  sb.append(" union all select 'PADM' tipo, null deseo, null preferencia, null nh, null fidelizacion, null religion,null comida, null idioma, null last_week,null next_month, to_char (nvl (a.fecha_preadmision, sysdate),'dd/mm/yyyy hh12:mi am') fecha_preadmision, null fecha_ingreso, null categoriadesc, null centroserviciodesc, null tot, 0 qty, null nombreplan, null nombreconvenio, null nombre_empresa,null,null,null,null from tbl_adm_admision a where a.estado = 'P' and a.pac_id = "); sb.append(pacId);
  
  sb.append(" union all select 'ADMA',null,null,null,null,null,null,null,null,null,null, to_char(a.fecha_ingreso,'dd/mm/yyyy'),(select descripcion from tbl_adm_categoria_admision where codigo = a.categoria) as categoriadesc, (select   descripcion from   tbl_cds_centro_servicio where codigo = a.centro_servicio) as centroserviciodesc, null, 0, null, null, null, null,null,null,null from tbl_adm_admision a where a.estado = 'A' and a.pac_id = "); sb.append(pacId);
  if (!admCat.trim().equals("1")) sb.append(" and a.centro_servicio = ");sb.append(pacId);
  
  
  
  sb.append(" union all select distinct 'BEN', null, null, null, null, null, null, null, null, null, null, null, null, null, null, a.secuencia, b.nombre as nombrePlan, c.nombre as nombreConvenio, d.nombre as nombreEmpresa, null,null,null,null from tbl_adm_beneficios_x_admision a, tbl_adm_plan_convenio b, tbl_adm_convenio c, tbl_adm_empresa d, tbl_adm_tipo_plan e, tbl_adm_tipo_poliza f, tbl_adm_clasif_x_tipo_adm g, tbl_adm_tipo_admision_cia h, tbl_adm_categoria_admision i where a.pac_id = ");sb.append(pacId);
  
  sb.append(" and a.admision=(select max(secuencia) - 1 from tbl_adm_admision where pac_id=");sb.append(pacId);
  
  sb.append(") and a.estado='A' and a.empresa=b.empresa and a.convenio=b.convenio and a.plan=b.secuencia and b.empresa=c.empresa and b.convenio=c.secuencia and b.estado='A' and c.empresa=d.codigo and c.estatus='A' and a.tipo_plan=e.tipo_plan and a.tipo_poliza=e.poliza and a.tipo_poliza=f.codigo and a.categoria_admi=g.categoria and a.tipo_admi=g.tipo and a.clasif_admi=g.codigo and g.categoria=h.categoria and g.tipo=h.codigo and h.categoria=i.codigo and a.prioridad = 1");
  sb.append(" union all select 'INFF',null,null,null,null,null,null,null,null,null,null,null, null, null, nvl(getDeuda("+compania+",'PAC',"+pacId+"),'0|0')tot,0 qty, null, null, null, null,null,null,null from dual ");
  if (mode.trim().equals("edit") || mode.trim().equals("view")){
	sb.append(" union all select 'RC',null,null,null,null,null,null,null,null,null,to_char(fecha,'dd/mm/yyyy')||' '||to_char(hora,'hh12:mi:ss am'),null, null, null, to_char(nvl(total,0)), 0, null, null, null, null,null,null,null from tbl_sal_escalas  where pac_id = ");sb.append(pacId);
	sb.append(" and admision = ");sb.append(noAdmision);
	sb.append(" and tipo = 'MO'");
  }
  sb.append(" order by 16 desc");
  
  ArrayList al = SQLMgr.getDataList(sb.toString());
%>
<div id="pacInfo" class="Text10">
	<div id="accordion"> 
	<%
	sb = new StringBuffer();
	String one = "", hlINFF = "", hlADMA = "", title = "", cssClass = "";
	String adma = "", padm = "", ben = "", inff = "", importantInfo = "", rc="";
	int rcVal = 0;
	if (!pacId.trim().equals("") && !pacId.trim().equals("0")){ 
	

	   for (int i = 0; i<al.size(); i++){ 
	     cdo = (CommonDataObject)al.get(i);
		 
	    if (cdo.getColValue("tipo").equals("PAC")){
	    String idF = cdo.getColValue("vip");
	
		if (idF.trim().equals("S")) {cssClass = " vip-vip"; title="VIP";}
		else if (idF.trim().equals("D")) {cssClass = " vip-dis"; title="DISTINGUIDO";}
		else if (idF.trim().equals("J")) {cssClass = " vip-jd"; title="JUNTA DIRECTIVA";}
		else if (idF.trim().equals("M")) {cssClass = " vip-med"; title="STAFF MEDICO";}
	   %>
		 <h3><span title="<%=title%>" class="vip<%=cssClass%>">Datos Generales</span></h3>
		 <div>
			 <%if(cssClass.trim().equals("")){%>
			 <span class="Text10Bold">Tipo Pac.</span>:&nbsp;<%=cdo.getColValue("fidelizacion")%><br />
			 <%}%>
			 <span class="Text10Bold">Naci&oacute;</span>:&nbsp;<%=cdo.getColValue("nh")%><br />
			 <span class="Text10Bold">Deseo</span>:&nbsp;<%=cdo.getColValue("deseo")%><br />
			 <span class="Text10Bold">Preferencia</span>:&nbsp;<%=cdo.getColValue("preferencia")%><br />
			 <span class="Text10Bold">Religi&oacute;n</span>:&nbsp;<%=cdo.getColValue("religion")%><br />
			 <span class="Text10Bold">Comida</span>:&nbsp;<%=cdo.getColValue("comida")%><br>
			 <span class="RedTextBold"><%=cdo.getColValue("last_week")%></span><br>
			 <span class="RedTextBold"><%=cdo.getColValue("next_month")%></span>
		 </div>
		 <% if (mode.trim().equals("edit") || mode.trim().equals("view")){
		   if (cdo.getColValue("condicion")!=null && cdo.getColValue("condicion").trim().equals("RIESGO DE CAIDA")) { %>
		   <input type="hidden" name="rie" id="rie" />
		  <%
		  }
		 %>
			<h3><span class="">Condici&oacute;n</span></h3>
			<div><%=cdo.getColValue("jubilado")%><br><%=cdo.getColValue("condicion")%></div>
		 <%}%>
	     <%
		 importantInfo = cdo.getColValue("obserAdm");
		 }
		if (cdo.getColValue("tipo").equals("PADM")){
			padm += cdo.getColValue("fecha_preadmision")+", ";
		}
		if (cdo.getColValue("tipo").equals("ADMA")){
            adma += "["+cdo.getColValue("fecha_ingreso")+"] ** "+cdo.getColValue("categoriadesc")+" ** "+cdo.getColValue("centroserviciodesc")+"<br /><br />";	
			hlADMA = "RedTextBold";
		}
		if (cdo.getColValue("tipo").equals("BEN")){
            ben += "["+cdo.getColValue("nombreplan")+"] ** "+cdo.getColValue("nombreconvenio")+" ** "+cdo.getColValue("nombreempresa")+"<br /><br />";	
		}
		if (cdo.getColValue("tipo").equals("INFF")){
		    if(cdo.getColValue("tot")!=null && !cdo.getColValue("tot").equals("") && !cdo.getColValue("tot").equals("0|0")){
			hlINFF = "RedTextBold";
                String tot = cdo.getColValue("tot","0|0");
				inff = "Cant.:"+tot.substring(0,tot.indexOf('|'))+", Monto: $"+tot.substring(tot.indexOf('|')+1)+"<br><input type='hidden' name='inff' id='inff' value='"+tot.substring(tot.indexOf('|')+1)+"' />";
			}
		}
		if (cdo.getColValue("tipo").equals("RC")){ // riesgo de caida desde expediente
		    rcVal = Integer.parseInt(cdo.getColValue("tot"));
			sb.append(cdo.getColValue("fecha_preadmision"));
			if(rcVal>=0&&rcVal<=24){
				sb.append(": <span style='color:green'>SIN RIESGO</span><br />");
			}else if(rcVal>=25&&rcVal<=50){
			    sb.append(": <span style='color:orange'>PRECAUCION</span><br />");
			}else if(rcVal>50){
			    sb.append(": <span style='color:red'>ALTO RIESGO</span><br />");
			}
			rc = "RedTextBold";
		}
		
	   }//for
	 %>
	 <h3 id="adm-hder"><span class="<%=hlADMA%>">Admisiones Activas</span></h3>
	 <div><%=adma.length()==0?"N/A":adma%></div>
	 <h3>Pre-admisi&oacute;n</h3>
	 <div><%=padm.length()==0?"N/A":padm%></div>
	 <h3>Beneficios</h3>
	 <div><strong><em>(Plan**Convenio**Empresa)</em></strong><br />
	 <%=ben.length()==0?"N/A":ben%></div>
	 <h3 id="inff-hder"><span class="<%=hlINFF%>">Saldos Pendientes</span></h3>
	 <div><span class="RedTextBold"><%=inff.length()==0?"N/A":inff%></span></div>
	 <%if(sb.length()>0){%>
		<h3><span class="<%=rc%>">Rieso ca&iacute;da (Expediente)</span></h3>
		<div><%=sb.toString()%></div>
	 <%}%>
	 <h3>Info.Importante</h3>
	 <div><%=importantInfo%></div>
	 <%if (adma.length()>0){%>
	 <input type='hidden' name='adma' id='adma' />
	 <%}%>
<%}else{%>
	 Error: No pudimos encontrar este paciente (<%=pacId%>)
<%}%>
	</div>
</div>