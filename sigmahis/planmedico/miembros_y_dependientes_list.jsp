<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);

if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer();
String estado = "", tipo = "", nombre = "", codigo = "", fechaFinAprob="", fechaIniAprob = "", fechaAprob = "", formaPago = "", cumpliran = "", anio = "", mostrar_inactivos = "S", mostrar_responsables = "S", mes = "";
boolean userClickedIrButton = false;
String cLang = (session.getAttribute("_locale")!=null?((java.util.Locale)session.getAttribute("_locale")).getLanguage():"es");
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy");
String fp=request.getParameter("fp") == null?"":request.getParameter("fp");

if(request.getMethod().equalsIgnoreCase("GET"))
{
int recsPerPage=100;
String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

    if(request.getParameter("mostrar_inactivos")!=null) mostrar_inactivos = request.getParameter("mostrar_inactivos");
    if(request.getParameter("mostrar_responsables")!=null) mostrar_responsables = request.getParameter("mostrar_responsables");
    if(request.getParameter("nombre")!=null) nombre = request.getParameter("nombre");
    if(request.getParameter("codigo")!=null) codigo = request.getParameter("codigo");
	if(request.getParameter("estado")!=null) {estado = request.getParameter("estado");userClickedIrButton = true;}
    if(request.getParameter("tipo")!=null) tipo = request.getParameter("tipo");
    if(request.getParameter("forma_pago")!=null) formaPago = request.getParameter("forma_pago");
    if(request.getParameter("cumpliran")!=null) cumpliran = request.getParameter("cumpliran");
    if(request.getParameter("anio")!=null) anio = request.getParameter("anio");
		else anio = cDate.substring(6, 10);
    if(request.getParameter("mes")!=null) mes = request.getParameter("mes");
		else mes = cDate.substring(3, 5);
    if(request.getParameter("fecha_ini_aprob")!=null) fechaIniAprob = request.getParameter("fecha_ini_aprob");
    else fechaIniAprob = cDate;
    if(request.getParameter("fecha_fin_aprob")!=null) fechaFinAprob = request.getParameter("fecha_fin_aprob");
    else fechaFinAprob = cDate;
    if(request.getParameter("fecha_aprob")!=null) fechaAprob = request.getParameter("fecha_aprob");
    else fechaAprob = cDate;
    
    if (!codigo.equals("")){
      sbFilter.append(" and c.codigo = ");
      sbFilter.append(codigo);
    }
   
    if (!tipo.equals("")){
      sbFilter.append(" and s.afiliados = ");
      sbFilter.append(tipo);
    }
    if (!estado.equals("")){
      sbFilter.append(" and s.estado = '");
      sbFilter.append(estado);
      sbFilter.append("' ");
    }    
		if (mostrar_inactivos.equals("N")){
      sbFilter.append(" and dc.estado != 'I' ");
    }		
		
		if (fp.equalsIgnoreCase("por_edad")){
			if (mostrar_responsables.equals("N")){
				sbFilter.append(" and dc.parentesco != 0 ");
			}
		}
    
    if (fp.equalsIgnoreCase("forma_pago")){
       if(!fechaAprob.equals("")){
         sbFilter.append(" and decode(s.estado,'A',trunc(s.fecha_modificacion)) <= to_date('");
         sbFilter.append(fechaAprob);
         sbFilter.append("','dd/mm/yyyy') ");
       }
       if (!formaPago.equals("")){
         sbFilter.append(" and t.tipo = '");
         sbFilter.append(formaPago);
         sbFilter.append("'");
       }
    }else if (fp.equalsIgnoreCase("por_edad")){
       if (!fechaIniAprob.equals("") && !fechaFinAprob.equals("")){
          /*sbFilter.append(" and c.fecha_nacimiento between to_date('");
          sbFilter.append(fechaIniAprob);
          sbFilter.append("','dd/mm/yyyy') and to_date('");
          sbFilter.append(fechaFinAprob);
          sbFilter.append("','dd/mm/yyyy') ");*/
                    
          sbFilter.append(" and to_char(fecha_nacimiento,'mm') = '");
          sbFilter.append(mes);
          sbFilter.append("'");

          /*sbFilter.append(" and trunc(fecha_nacimiento) between to_date('");
          sbFilter.append(fechaIniAprob);
          sbFilter.append("', 'dd/mm/yyyy') and to_date('");
          sbFilter.append(fechaFinAprob);
          sbFilter.append("', 'dd/mm/yyyy')");*/

					
				}
    }else{
        if (!fechaIniAprob.equals("") && !fechaFinAprob.equals("")){
          sbFilter.append(" and decode(s.estado,'A',trunc(s.fecha_modificacion)) between to_date('");
          sbFilter.append(fechaIniAprob);
          sbFilter.append("','dd/mm/yyyy') and to_date('");
          sbFilter.append(fechaFinAprob);
          sbFilter.append("','dd/mm/yyyy') ");
        }
    }
    
    if (!cumpliran.equals("")){
        if (cumpliran.equals("0")){
            sbFilter.append(" and trunc(months_between(trunc(sysdate),c.fecha_nacimiento) / 12) in(19,60)");
        }else{
					sbFilter.append(" and trunc(months_between(last_day(to_date('");
          sbFilter.append(mes);
          sbFilter.append("/");
          sbFilter.append(anio);
          sbFilter.append("','mm/yyyy')),c.fecha_nacimiento) / 12) = ");
					sbFilter.append(cumpliran);
					//sbFilter.append(" /*and mod(trunc(months_between(trunc(sysdate),c.fecha_nacimiento)),12) between 10 and 11 */");
        }
    }

	sbSql.append("select ");
    if (fp.equalsIgnoreCase("por_edad")){
      sbSql.append(" distinct ");
    }

    sbSql.append(" lpad(s.id, 10, '0') id_sol_plan, s.afiliados as tipo_plan, t.tipo forma_pago,  decode(s.estado,'A',to_char(s.fecha_modificacion,'dd/mm/yyyy')) as fecha_aprobacion, c.codigo id_cliente,c.primer_nombre||decode(c.segundo_nombre,null,'',' '||c.segundo_nombre) ||' '|| c.primer_apellido||decode(c.segundo_apellido,null,'',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,'',' '||c.apellido_de_casada)) nombre_cliente, nvl((select sum(costo_mensual) from tbl_pm_sol_contrato_det where id_cliente = s.id_cliente and id_solicitud = s.id), 0) costo_mensual, decode(s.afiliados,1,'Plan Familiar','Plan Tercera Edad') tipo_plan_desc, s.estado, decode(s.estado,'A','Aprobado','I','Inactivo','P','Pendiente') as estado_desc, get_age(c.fecha_nacimiento,sysdate,'d') as edad, s.id, decode(t.tipo, 'V', 'Voluntario', 'T', 'Tarjeta Credito', 'C', 'ACH') forma_pago_desc, to_char(c.fecha_nacimiento,'dd/mm/yyyy') as fn, (select nombre_banco banco from tbl_adm_ruta_transito r where r.ruta = t.cod_banco) banco, t.num_tarjeta_cta, c.id_paciente, c.telefono||'/'||c.telefono_movil telefonos, to_char(s.fecha_ini_plan, 'dd/mm/yyyy') fecha_ini_plan from vw_pm_cliente c , tbl_pm_solicitud_contrato s, tbl_pm_cta_tarjeta t ");
    if (fp.equalsIgnoreCase("por_edad")){
        sbSql.append(" , tbl_pm_sol_contrato_det dc ");
    }   
    
    sbSql.append(" where s.fecha_ini_plan is not null ");
    if (!fp.equalsIgnoreCase("por_edad")){
        sbSql.append(" and c.codigo = s.id_cliente  ");
    } else{
        if(!estado.equals("F")) sbSql.append(" and s.estado in ('A') and s.id = dc.id_solicitud  and (s.id_cliente = c.codigo or dc.id_cliente = c.codigo) and c.codigo is not null ");
        else sbSql.append(" and s.id = dc.id_solicitud  and (s.id_cliente = c.codigo or dc.id_cliente = c.codigo) and c.codigo is not null ");
    }
		sbSql.append(" and s.id = t.id_solicitud  and t.estado = 'A'");
		

    sbSql.append(sbFilter.toString());
    
    if (fp.equalsIgnoreCase("forma_pago")) sbSql.append(" order by 3, s.id ");
	else if (fp.equalsIgnoreCase("por_edad")) sbSql.append(" order by 2, 14");
	else sbSql.append(" order by 2, s.fecha_modificacion desc ");
	
	if (userClickedIrButton){
    al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);
    rowCount = CmnMgr.getCount("SELECT count(*) FROM ("+sbSql.toString()+")");
	}

	if (searchDisp!=null) searchDisp=searchDisp;
  else searchDisp = "Listado";

  if (!searchVal.equals("")) searchValDisp=searchVal;
  else searchValDisp="Todos";

  int nVal, pVal;
  int preVal=Integer.parseInt(previousVal);
  int nxtVal=Integer.parseInt(nextVal);

  if (nxtVal<=rowCount) nVal=nxtVal;
  else nVal=rowCount;

  if(rowCount==0) pVal=0;
  else pVal=preVal;

%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script>
document.title = 'Plan Medicico - Reportes - '+document.title;
function doAction(){}
function showClieList(){abrir_ventana("../planmedico/pm_sel_cliente.jsp?fp=rpt_miembros");}

$(document).ready(function(){
   $("#printImg").click(function(){
		 var fDesde = '', fHasta = '', codigo = '', tipo = '', estado = '';
		 <%if(fp.equals("forma_pago")){%>
		 fDesde = document.search01.fecha_aprob.value;
		 <%} else if(fp.equals("por_edad")){%>
		 <%} else {%>
		 fDesde = document.search01.fecha_ini_aprob.value;
		 fHasta = document.search01.fecha_fin_aprob.value;
		 codigo = document.search01.codigo.value;
		 tipo = document.search01.tipo.value||'ALL';
		 estado = document.search01.estado.value;
		 
		 <%}%>
     <%if(fp.equals("")){%>
		 abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=planmedico/rpt_miembros_depend_list.rptdesign&desdeParam='+fDesde+'&hastaParam='+fHasta+'&tipoParam='+tipo+'&estadoParam='+estado+'&codParam='+codigo);
		<%} else {%> 
		abrir_ventana("../planmedico/print_miembros_dependientes.jsp?appendFilter=<%=IBIZEscapeChars.forURL(sbFilter.toString())%>&fp=<%=fp%>&selId="+$("#curId").val());
		<%}%>
   });
});
function setId(val){return $("#curId").val(val);}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Plan Medicico - Mantenimiento - Empresa"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
<%fb = new FormBean("dummyForm",request.getContextPath()+"/common/urlRedirect.jsp");%>
<%=fb.formStart()%>
	<tr class="TextRow02">
		<td colspan="4" align="right" style="cursor:pointer">
			<authtype type='2'>
			<img src="../images/printer.png" alt="Imprimir" id="printImg"/>
			</authtype>
		</td>
	</tr>
<%=fb.formEnd(true)%>
	<tr class="TextFilter">
<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

		<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
			<%=fb.formStart()%>
			<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
			<%=fb.hidden("fp",fp)%>
		  <td colspan="2">
          <%if(fp.equalsIgnoreCase("forma_pago")){%>
               <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="fecha_aprob" />
				<jsp:param name="valueOfTBox1" value="<%=fechaAprob%>" />
				<jsp:param name="fromLbl" value="Aprobaci�n desde" />
			</jsp:include>
            &nbsp;&nbsp;
            <cellbytelabel>Forma Pago</cellbytelabel>
            <%=fb.select("forma_pago","T=Tarjeta de Credito, C=ACH, V=Pago Voluntario", formaPago,"T")%>
            
          <%}else{%>
          &nbsp;<cellbytelabel>Nombre</cellbytelabel>&nbsp;
		  <%=fb.textBox("codigo",codigo,false,false,true,5,4,null,null,"")%>
		  <%=fb.textBox("nombre",nombre,false,false,true,30,200,null,null,"")%>
		  <%=fb.button("btnClie","...",false,false,null,null,"onclick=showClieList()")%>
          <%if(fp.equalsIgnoreCase("por_edad")){%>
					Mes/A&ntilde;o:
					<%=fb.select("mes","01=ENERO,02=FEBRERO,03=MARZO,04=ABRIL,05=MAYO,06=JUNIO,07=JULIO,08=AGOSTO,09=SEPTIEMBRE,10=OCTUBRE,11=NOVIEMBRE,12=DICIEMBRE", mes,"")%>					
					<%=fb.textBox("anio",anio,false,false,false,4,4,null,null,"")%>
					<%} else {%>
          <jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="2" />
				<jsp:param name="nameOfTBox1" value="fecha_ini_aprob" />
				<jsp:param name="valueOfTBox1" value="<%=fechaIniAprob%>" />
				<jsp:param name="nameOfTBox2" value="fecha_fin_aprob" />
				<jsp:param name="valueOfTBox2" value="<%=fechaFinAprob%>" />
				<jsp:param name="fieldClass" value="Text10" />
				<jsp:param name="buttonClass" value="Text10" />
				<jsp:param name="fromLbl" value="<%=fp.equalsIgnoreCase("por_edad")?"F.Cumpl. Desde":"Aprobaci�n Desde"%>" />
			</jsp:include>
          <%}}%>
                
            <cellbytelabel>Tipo</cellbytelabel>
						<%if(fp.equalsIgnoreCase("por_edad")){%>
            <%=fb.select("tipo","1=PLAN FAMILIAR", tipo,"")%>
						<%} else {%>
						<%=fb.select("tipo","1=PLAN FAMILIAR,2=PLAN TERCERA EDAD", tipo,"T")%>
            <%}%>
            
            <%if(fp.equalsIgnoreCase("por_edad")){%>
              <cellbytelabel>Edad que cumplir&aacute;</cellbytelabel> 
              <%//=fb.select("cumpliran","19=Cumplir� 19 A�os,30=Cumplir� 30 A�os,40=Cumplir� 40 A�os,60=Cumplir� 60 A�os", cumpliran,"T")%>
							<%=fb.textBox("cumpliran",cumpliran,false,false,false,3,3,null,null,"")%>
            <%}%>
          
			&nbsp;<cellbytelabel>Estado</cellbytelabel>&nbsp;
			<%=fb.select("estado","A=Aprobado,P=Pendiente,I=Inactivo, F=Finalizado",estado,"")%>
			<%if(fp.equals("por_edad")){%>
			Mostrar Inactivos?
			<%=fb.select("mostrar_inactivos","S=Si,N=NO",mostrar_inactivos,"")%>
			Mostrar Responsables?
			<%=fb.select("mostrar_responsables","S=Si,N=NO",mostrar_responsables,"")%>
			<%}%>
			<%=fb.submit("go","Ir")%></td>
		<%=fb.formEnd()%>
	<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_ini_aprob",fechaIniAprob)%>
				<%=fb.hidden("fecha_fin_aprob",fechaFinAprob)%>
                <%=fb.hidden("fp",fp)%>
                <%=fb.hidden("fecha_aprob",fechaAprob)%>
                <%=fb.hidden("forma_pago",formaPago)%>
                <%=fb.hidden("cumpliran",cumpliran)%>
                <%=fb.hidden("mes",mes)%>
                <%=fb.hidden("anio",anio)%>
                <%=fb.hidden("mostrar_inactivos",mostrar_inactivos)%>
                <%=fb.hidden("mostrar_responsables",mostrar_responsables)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel>  <%=pVal%><cellbytelabel id="7"> hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
                <%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo",tipo)%>
                <%=fb.hidden("fp",fp)%>
                <%=fb.hidden("fecha_aprob",fechaAprob)%>
                <%=fb.hidden("forma_pago",formaPago)%>
				<%=fb.hidden("fecha_ini_aprob",fechaIniAprob)%>
                <%=fb.hidden("cumpliran",cumpliran)%>
				<%=fb.hidden("fecha_fin_aprob",fechaFinAprob)%>	
                <%=fb.hidden("mes",mes)%>
                <%=fb.hidden("anio",anio)%>
                <%=fb.hidden("mostrar_inactivos",mostrar_inactivos)%>
                <%=fb.hidden("mostrar_responsables",mostrar_responsables)%>
								<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">
<table align="center" width="100%" cellpadding="0" cellspacing="1">
	<tr class="TextHeader">
		<td width="10%" align="center">&nbsp;<cellbytelabel>#Contrato</cellbytelabel></td>
		<td width="15%">&nbsp;<cellbytelabel>Cliente</cellbytelabel></td>
        <%if(!fp.equalsIgnoreCase("forma_pago")){%>
            <td width="5%" align="center">&nbsp;<cellbytelabel>Edad</cellbytelabel></td>
            <td width="10%" align="center">&nbsp;<cellbytelabel>F.<%=fp.equalsIgnoreCase("por_edad")?"Nacimiento":"Aprobaci&oacute;n"%></cellbytelabel></td>
        <%}else{%>
            <td width="10%" align="center">&nbsp;<cellbytelabel>No. Cuenta</cellbytelabel></td>
            <td width="10%">&nbsp;<cellbytelabel>Banco</cellbytelabel></td>
        <%}%>
        <%if(!fp.equalsIgnoreCase("por_edad")){%>
            <td width="10%" align="right"><cellbytelabel>Cuota</cellbytelabel></td>
        <%}%>
		<td width="10%" align="center"><cellbytelabel>Estado</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Identificaci&oacute;n</cellbytelabel></td>
		<!--<td width="10%" align="center"><cellbytelabel>Fecha Nac.</cellbytelabel></td>-->
		<td width="10%" align="center"><cellbytelabel>Fecha Ing.</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Fecha Salida</cellbytelabel></td>
		<td width="10%" align="center"><cellbytelabel>Telefonos</cellbytelabel></td>
		<td width="5%">&nbsp;</td>
	</tr>
   
    
    
	<%fb = new FormBean("form00",request.getContextPath()+"/common/urlRedirect.jsp");%>
	<%=fb.formStart()%>
	<%=fb.hidden("curId","")%>
<%
				
				String groupBy1 = "";
                String grpHdr = fp.equalsIgnoreCase("forma_pago") ? "forma_pago" : "tipo_plan";
                String grpHdrDesc = fp.equalsIgnoreCase("forma_pago") ? "forma_pago_desc" : "tipo_plan_desc";
				for (int i=0; i<al.size(); i++)
				{
				 CommonDataObject cdo = (CommonDataObject) al.get(i);
				 String color = "TextRow02";
				 if (i % 2 == 0) color = "TextRow01";
				 				 
				 if (!groupBy1.equals(cdo.getColValue(grpHdr))){	 
				 %>
				     <tr class="TextHeader01">
				       <td colspan="11">[<%=cdo.getColValue(grpHdr)%>] <%=cdo.getColValue(grpHdrDesc)%></td>
				     </tr>
				 <%}%>
				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">&nbsp;<%=cdo.getColValue("id_sol_plan")%></td>
					<td>[<%=cdo.getColValue("id_cliente")%>] <%=cdo.getColValue("nombre_cliente")%></td>
                    <%if(!fp.equalsIgnoreCase("forma_pago")){%>
                        <td align="center">&nbsp;<%=cdo.getColValue("edad")%></td>
                        <td align="center"><%=fp.equalsIgnoreCase("por_edad")?cdo.getColValue("fn"):cdo.getColValue("fecha_aprobacion")%></td>
                    <%}else{%>
                       <td align="center"><%=(!cdo.getColValue("num_tarjeta_cta").equals("")?CmnMgr.getDecryptToShow(cdo.getColValue("num_tarjeta_cta")):"")%></td>
                       <td align="center"><%=cdo.getColValue("banco")%></td>
                    <%}%>
                    <%if(!fp.equalsIgnoreCase("por_edad")){%>
					<td align="right">&nbsp;<%=CmnMgr.getFormattedDecimal(cdo.getColValue("costo_mensual"))%></td>
                    <%}%>
					<td align="center">&nbsp;<%=cdo.getColValue("estado_desc")%></td>
					<td align="center">&nbsp;<a href="javascript:abrir_ventana('../planmedico/reg_solicitud.jsp?mode=add&fp=adenda&id=<%=cdo.getColValue("id_sol_plan")%>&id_motivo=0')"><%=cdo.getColValue("id_paciente")%></a></td>
					<!--<td align="center">&nbsp;<%=cdo.getColValue("fn")%></td>-->
					<td align="center">&nbsp;<%=cdo.getColValue("fecha_ini_plan")%></td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;<%=cdo.getColValue("telefonos")%></td>
					<td align="center">
					  <%=fb.radio("radioVal","",false,false,false,null,null,"onclick=setId("+cdo.getColValue("id")+")")%>
					</td>
				</tr>
			
				<%
				groupBy1 = cdo.getColValue(grpHdr);
				}
				%>
<%=fb.formEnd(true)%>
</table>
	</td>
</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%
				fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_ini_aprob",fechaIniAprob)%>
				<%=fb.hidden("fecha_fin_aprob",fechaFinAprob)%>
                <%=fb.hidden("fp",fp)%>
                <%=fb.hidden("forma_pago",formaPago)%>
                <%=fb.hidden("fecha_aprob",fechaAprob)%>
                <%=fb.hidden("cumpliran",cumpliran)%>
                <%=fb.hidden("mes",mes)%>
                <%=fb.hidden("anio",anio)%>
                <%=fb.hidden("mostrar_inactivos",mostrar_inactivos)%>
                <%=fb.hidden("mostrar_responsables",mostrar_responsables)%>
					<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
					<%=fb.formEnd()%>
					<td width="40%"><cellbytelabel id="5">Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel id="6">Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel id="7"> hasta</cellbytelabel> <%=nVal%></td>
					<%
					fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");
					%>
					<%=fb.formStart()%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
					<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
					<%=fb.hidden("searchOn",searchOn)%>
					<%=fb.hidden("searchVal",searchVal)%>
					<%=fb.hidden("searchValFromDate",searchValFromDate)%>
					<%=fb.hidden("searchValToDate",searchValToDate)%>
					<%=fb.hidden("searchType",searchType)%>
					<%=fb.hidden("searchDisp",searchDisp)%>
					<%=fb.hidden("searchQuery","sQ")%>
          <%=fb.hidden("nombre",nombre)%>
				<%=fb.hidden("codigo",codigo)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("tipo",tipo)%>
				<%=fb.hidden("fecha_ini_aprob",fechaIniAprob)%>
				<%=fb.hidden("fecha_fin_aprob",fechaFinAprob)%>
                <%=fb.hidden("fp",fp)%>
                <%=fb.hidden("forma_pago",formaPago)%>
                <%=fb.hidden("fecha_aprob",fechaAprob)%>
                <%=fb.hidden("cumpliran",cumpliran)%>
                <%=fb.hidden("mes",mes)%>
                <%=fb.hidden("anio",anio)%>
                <%=fb.hidden("mostrar_inactivos",mostrar_inactivos)%>
                <%=fb.hidden("mostrar_responsables",mostrar_responsables)%>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
					<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>
</html>
<%
}
%>