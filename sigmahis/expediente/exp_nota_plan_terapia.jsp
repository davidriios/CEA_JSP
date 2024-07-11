<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Hashtable" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al1 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

boolean viewMode = false;
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String tipo = request.getParameter("tipo");
//String tipo = "PDT";
String code = request.getParameter("code");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String evalPor = "";
String color = "";

/* -----  TIPO -------
NDP = NOTA DE PROGRESO
PDT = PLAN DE TRATAMIENTO
*/

if (mode == null || mode.equals("")) mode = "add";
if (modeSec == null || modeSec.equals("")) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (tipo == null) throw new Exception("El Tipo no es válido. Por favor intente nuevamente!");
if (code == null) code = "0";
if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	// ----------------------------------- query para el historial -------------------------------------------------- //
	StringBuffer sbSql1 = new StringBuffer();
	sbSql1.append("select codigo, to_char(fecha,'dd/mm/yyyy') fecha_a, to_char(fecha,'hh12:mi:ss am') hora, evaluado_por from tbl_sal_nota_plan_terapia where tipo = '");
	sbSql1.append(tipo);
	sbSql1.append("' and pac_id = ");
	sbSql1.append(pacId);
	sbSql1.append(" and secuencia = ");
	sbSql1.append(noAdmision);
	sbSql1.append(" order by fecha desc");
	
	al1= SQLMgr.getDataList(sbSql1.toString());
	
	StringBuffer sbSql2 = new StringBuffer();
	
	if(!code.equals("0")){
	    sbSql2.append("select codigo, to_char(fecha,'dd/mm/yyyy') fecha, to_char(fecha,'hh12:mi am') hora, evaluado_por ");
	    if(tipo.equalsIgnoreCase("NDP")) sbSql2.append(" , frecuencia_nota ");
	    sbSql2.append(" ,problemas, metodo, plan");
	    if(tipo.equalsIgnoreCase("PDT")) sbSql2.append(", RESUMEN_EVAL, INTERPRETACION, OBJETIVOS, GRADO_METODO ");
		sbSql2.append(" from tbl_sal_nota_plan_terapia where codigo = ");
		sbSql2.append(code);	
		cdo = SQLMgr.getData(sbSql2.toString());
	}
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'EXPEDIENTE - '+document.title;
function doAction(){newHeight();}
function verEval(k){var code = eval('document.form0.code'+k).value ;window.location = '../expediente/exp_nota_plan_terapia.jsp?&modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code='+code+'&tipo=<%=tipo%>&desc=<%=desc%>';}
function add(){window.location = '../expediente/exp_nota_plan_terapia.jsp?&modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=<%=tipo%>&desc=<%=desc%>';}
function printExp(){abrir_ventana('../expediente/print_exp_nota_plan_terapia.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tipo=<%=tipo%>&seccion=<%=seccion%>&code=<%=code%>&desc=<%=desc%>');}
function checkFrec(){var element = document.form0.frecuencia_nota;var cnt = element.length;if (element[0].checked == true || element[1].checked == true ){return true;}else{return false;}}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
  <tr>
	 <td>
		<table width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("modeSec",modeSec)%>
			<%=fb.hidden("seccion",seccion)%>
			<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
			<%=fb.hidden("dob","")%>
			<%=fb.hidden("codPac","")%>
			<%=fb.hidden("pacId",pacId)%>
			<%=fb.hidden("noAdmision",noAdmision)%>
			<%=fb.hidden("desc",desc)%>
            <%=fb.hidden("tipo",tipo)%>
            <%fb.appendJsValidation("if(!checkFrec()){alert('Por favor escoge una Frecuencia de Nota!!');document.form0.evaluado_por.focus();error++;}");%>

 <!----------------------------   IMPRIMIENDO LA PRIMERA PARTE (HISTORAL) -------------------------->      
            <tr>
			   <td style="text-decoration:none;" colspan="3">
			     <div id="listado" width="100%" class="exp h100">
			     <div id="detListado" class="child">
			      <table width="100%" cellpadding="1" cellspacing="0">
					 <tr class="TextRow02">
						<td>&nbsp;<cellbytelabel id="1">Listado de Evaluaciones [ Terapia ]</cellbytelabel></td>
                        <td>&nbsp;</td>
                     <td align="right">
                     <a class="Link00" href="javascript:printExp()">[ <cellbytelabel id="2">Imprimir</cellbytelabel> ]</a> &nbsp;&nbsp;
                     <%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00">[ <cellbytelabel id="3">Agregar</cellbytelabel> ]</a><%}%></td>
					 </tr>
					 <tr class="TextHeader" align="center">
						<td><cellbytelabel id="4">Fecha</cellbytelabel></td>
						<td><cellbytelabel id="5">Hora</cellbytelabel></td>
						<td><cellbytelabel id="6">Evaluador</cellbytelabel></td>
					 </tr>
<%
for (int i = 1; i<=al1.size(); i++){
	 cdo1 = (CommonDataObject) al1.get(i-1);
	     color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01"; 
%>
        <%=fb.hidden("code"+i,cdo1.getColValue("codigo"))%>
		<%=fb.hidden("fecha"+i,cdo1.getColValue("fecha_a"))%>
		<%=fb.hidden("hora"+i,cdo1.getColValue("hora"))%>
        <%=fb.hidden("codigo"+i,cdo1.getColValue("codigo"))%>
     
  
                    <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer " onClick="javascript:verEval(<%=i%>)" align="center">
				       <td><%=cdo1.getColValue("fecha_a")%></td>
				       <td><%=cdo1.getColValue("hora")%></td>
				       <td><%=cdo1.getColValue("evaluado_por")%></td>
                     </tr>   
<%
} //end for historial
%>                  </table>
					</div>
					</div>
				 </td>
			 </tr>
<!----------------------------   //   -------------------------->   
    
		<tr class="TextRow02" >
			<td><cellbytelabel id="4">Fecha</cellbytelabel>&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1" />
										<jsp:param name="clearOption" value="true" />
										<jsp:param name="nameOfTBox1" value="fecha" />
										<jsp:param name="format" value="dd/mm/yyyy"/>
										<jsp:param name="valueOfTBox1" value="<%=(code.trim().equals("0")?cDateTime.substring(0,10):cdo.getColValue("fecha"))%>" />
										<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("view"))?"y":"n"%>"/>
										</jsp:include></td>

			 <td>
										<cellbytelabel id="5">Hora</cellbytelabel>  &nbsp;&nbsp;&nbsp;&nbsp;
										<jsp:include page="../common/calendar.jsp" flush="true">
										<jsp:param name="noOfDateTBox" value="1"/>
										<jsp:param name="format" value="hh12:mi:ss am"/>
										<jsp:param name="nameOfTBox1" value="hora" />
										<jsp:param name="valueOfTBox1" value="<%=(code.trim().equals("0")?cDateTime.substring(11):cdo.getColValue("hora"))%>" />
										<jsp:param name="readonly" value="<%=(viewMode||modeSec.trim().equals("view"))?"y":"n"%>"/>
										</jsp:include></td>
                                        <td>&nbsp;</td>
		</tr>
        <%
		if(code.trim().equals("0")){
			evalPor = UserDet.getUserName()+" ("+UserDet.getName()+" )";
		}else evalPor = cdo.getColValue("evaluado_por");
		%>
        
        <tr class="TextRow01">
          <td><cellbytelabel id="7">Evaluado por</cellbytelabel></td> 
          <td><%=fb.textBox("evaluado_por",evalPor,true,false,true,60,"Text10","","")%></td>
          <td>&nbsp;</td> 
        </tr>
        
        <% if(tipo.equalsIgnoreCase("PDT")){ %>
        <tr class="TextRow01">
          <td><cellbytelabel id="8">Resumen de la Evaluaci&oacute;n</cellbytelabel></td> 
          <td><%=fb.textarea("resumen_eval",cdo.getColValue("resumen_eval"),false,false,viewMode,40,2,1000,"","","")%></td>
          <td>&nbsp;</td> 
        </tr>
        <%}%>
        <% if(tipo.equalsIgnoreCase("NDP")){%>
        <tr class="TextRow07">
          <td><cellbytelabel id="9">Frecuencia de la Nota</cellbytelabel></td> 
          <td>
		  <%=fb.radio("frecuencia_nota","D",(cdo.getColValue("frecuencia_nota")!=null && cdo.getColValue("frecuencia_nota").equalsIgnoreCase("D")),viewMode,false,null,null,"onClick=\"checkFrec()\"")%> <cellbytelabel id="10">DIARIA</cellbytelabel> &nbsp;
          <%=fb.radio("frecuencia_nota","S",(cdo.getColValue("frecuencia_nota")!=null && cdo.getColValue("frecuencia_nota").equalsIgnoreCase("S")),viewMode,false,null,null,"onClick=\"checkFrec()\"")%> <cellbytelabel id="11">SEMANAL</cellbytelabel>
          </td>
          <td>&nbsp;</td> 
        </tr>
        <%}%>
        
        <tr class="TextRow01">
          <td><cellbytelabel id="12">Problemas Encontrados</cellbytelabel></td> 
          <td><%=fb.textarea("problemas",cdo.getColValue("problemas"),false,false,viewMode,40,2,2000,"","","")%></td>
          <td>&nbsp;</td> 
        </tr>
        
         <% if(tipo.equalsIgnoreCase("PDT")){ %>
        <tr class="TextRow01">
          <td><cellbytelabel id="13">Interpretaci&oacute;n</cellbytelabel></td> 
          <td><%=fb.textarea("interpretacion",cdo.getColValue("interpretacion"),false,false,viewMode,40,2,1000,"","","")%></td>
          <td>&nbsp;</td> 
        </tr>
        
        <tr class="TextRow01">
          <td><cellbytelabel id="14">Objetivos</cellbytelabel></td> 
          <td><%=fb.textarea("objetivos",cdo.getColValue("objetivos"),false,false,viewMode,40,2,1000,"","","")%></td>
          <td>&nbsp;</td> 
        </tr>
        <%}%>
        
        <tr class="TextRow01">
          <td><cellbytelabel id="15">M&eacute;todo</cellbytelabel></td> 
          <td><%=fb.textarea("metodo",cdo.getColValue("metodo"),false,false,viewMode,40,2,2000,"","","")%></td>
          <td>&nbsp;</td> 
        </tr>
          
        <% if(tipo.trim().equals("PDT")){%>
         <tr class="TextRow01">
          <td><cellbytelabel id="16">Graduaci&oacute;n del M&eacute;todo</cellbytelabel></td> 
          <td><%=fb.textarea("grado_metodo",cdo.getColValue("grado_metodo"),false,false,viewMode,40,1,60,"","","")%></td>
          <td>&nbsp;</td> 
        </tr>
        <%}%> 
        
        <tr class="TextRow01">
          <td><cellbytelabel id="17">Plan</cellbytelabel></td> 
          <td><%=fb.textarea("plan",cdo.getColValue("plan"),false,false,viewMode,40,2,2000,"","","")%></td>
          <td>&nbsp;</td> 
        </tr>
       
   		<tr class="TextRow02">
			<td colspan="3" align="right">
				<cellbytelabel id="18">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="19">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="20">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
</body>
</html>
<%

}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	  if (modeSec.trim().equals("add")){  
		
	        cdo = new CommonDataObject();
		
		    cdo.setTableName("tbl_sal_nota_plan_terapia");
		    cdo.addColValue("pac_id",request.getParameter("pacId"));
		    cdo.addColValue("secuencia",request.getParameter("noAdmision"));
			cdo.addColValue("fecha",cDateTime);
			cdo.addColValue("evaluado_por",request.getParameter("evaluado_por"));
			cdo.addColValue("problemas",request.getParameter("problemas"));
			cdo.addColValue("metodo",request.getParameter("metodo"));
			cdo.addColValue("plan",request.getParameter("plan"));
			cdo.addColValue("tipo",tipo);
			
			if(tipo.equals("NDP") && request.getParameter("frecuencia_nota") !=null){
			    cdo.addColValue("frecuencia_nota",request.getParameter("frecuencia_nota"));
			}
			
			if(tipo.equals("PDT")){
			    cdo.addColValue("resumen_eval",request.getParameter("resumen_eval"));
			    cdo.addColValue("interpretacion",request.getParameter("interpretacion"));
				cdo.addColValue("objetivos",request.getParameter("objetivos"));
				cdo.addColValue("grado_metodo",request.getParameter("grado_metodo"));
			}
			

            

			cdo.setAutoIncCol("codigo");
		    cdo.addPkColValue("codigo","");
			
			SQLMgr.insert(cdo);
			code = SQLMgr.getPkColValue("codigo");
			
		   ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		   ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_list.jsp"))
	{
%>
//	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_list.jsp")%>';
<%
	}
	else
	{
%>
//	window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_list.jsp';
<%
	}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	parent.doRedirect(0);
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function addMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>';}
function editMode(){window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=request.getParameter("noAdmision")%>&desc=<%=desc%>&code=<%=code%>&tipo=<%=tipo%>';}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
} // POST
%>