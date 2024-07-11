<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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
**/

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alEval = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoEval = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();

boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String code = request.getParameter("code");
String from = request.getParameter("from");
String medico = request.getParameter("medico");

if (code == null) code = "0";
if (mode == null || mode.equals("")) mode = "add";
if (modeSec == null || modeSec.equals("")) modeSec = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (from == null) from = "";
if (medico == null) medico = "";
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String change = request.getParameter("change");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	
	sql="select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, EKG from TBL_SAL_PROCEDIMIENTO_PACIENTE where pac_id="+pacId+" and secuencia="+noAdmision +" order by FECHA_CREAC DESC";
	
	alEval = SQLMgr.getDataList(sql);
	
	
	if(!code.trim().equals("0")){
		sql="select CODIGO, DESCRIPCION, USUARIO_CREAC, to_char(FECHA_CREAC,'dd/mm/yyyy hh12:mi:ss am') as FECHA_CREAC, USUARIO_MODIF, to_char(FECHA_MODIF,'dd/mm/yyyy hh12:mi:ss am') as FECHA_MODIF, EKG from TBL_SAL_PROCEDIMIENTO_PACIENTE where pac_id="+pacId+" and secuencia="+noAdmision+ " and CODIGO = "+code;
	
	cdo1 = SQLMgr.getData(sql);
	}
	
%>

<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'EXPEDIENTE-PROCEDIMIENTO  - '+document.title;
<%@ include file="../expediente/exp_checkviewmode.jsp"%>
function doAction(){newHeight();document.form0.medico.value = <%=from.equals("salida_pop")? "'"+medico+"'" : "parent.document.paciente.medico.value"%>;checkViewMode();setFormaSolicitud($("input[name='formaSolicitudX']:checked").val());}
function imprimir(fg){abrir_ventana('../expediente/print_exp_seccion_23.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&code=<%=code%>&fg='+fg);}
function setOMProcedimientos(p){var code = eval('document.form0.codigo'+p).value;window.location = '../expediente/exp_procedimientos.jsp?modeSec=view&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&medico=<%=medico%>&from=<%=from%>&code='+code;}
function add(){window.location = '../expediente/exp_procedimientos.jsp?modeSec=add&mode=<%=mode%>&seccion=<%=seccion%>&pacId=<%=pacId%>&desc=<%=desc%>&noAdmision=<%=noAdmision%>&medico=<%=medico%>&from=<%=from%>&code=0';}

function consultas(){
  abrir_ventana('../expediente/ordenes_medicas_list.jsp?pac_id=<%=pacId%>&no_admision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>&fg=exp_seccion&tipo_orden=12&interfaz=');
}
function setFormaSolicitud(val){document.form0.formaSolicitud.value=val;}
function showMedicList(){abrir_ventana1('../common/search_medico.jsp?fp=expOrdenesMed');}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="<%=desc%>"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0" >
	<tr>
		<td>
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1" >
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
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
                 <%=fb.hidden("code",code)%>
				 <%=fb.hidden("medico",medico)%>
				 <%=fb.hidden("from",from)%>
				 <%=fb.hidden("formaSolicitud","")%>
                  
                  <tr class="TextRow01">
   <td>
       <div id="proc" width="100%" class="exp h150">
	   <div id="proced" width="98%" class="child">
       
       <table width="100%" cellpadding="1" cellspacing="0">
       <tr class="TextRow02">
								<td align="right" colspan="4">
                                <a href="javascript:consultas()" class="Link00Bold">[ <cellbytelabel>Consultar</cellbytelabel> ]</a>
                                <%if(!mode.trim().equals("view")){%><a href="javascript:add()" class="Link00Bold">[ <cellbytelabel>Agregar Procedimientos</cellbytelabel> ]</a><%}%> <a href="javascript:imprimir('')" class="Link00Bold">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a><a href="javascript:imprimir('TD')" class="Link00Bold">[ <cellbytelabel>Imprimir Todo</cellbytelabel>]</a></td>
							</tr>

                <tr class="TextHeader">
                    <td colspan="4">LISTADO DE PROCEDIMIENTOS</td>
                 </tr>
							<tr class="TextHeader">
                            	<td width="15%"><cellbytelabel>C&oacute;digo</cellbytelabel></td>
								<td width="15%"><cellbytelabel>Fecha</cellbytelabel></td>
								<td width="70%">&nbsp;</td>
				           </tr>
                           <%
						   for (int p = 1; p<=alEval.size(); p++){
							    cdoEval = (CommonDataObject)alEval.get(p-1);
								String color = "TextRow02";
		                        if (p % 2 == 0) color = "TextRow01";
								%>
                           
                           <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" onClick="javascript:setOMProcedimientos(<%=p%>)" style="text-decoration:none; cursor:pointer">
                           <td width="15%"><%=cdoEval.getColValue("CODIGO")%></td>
                           <td width="70%"><%=cdoEval.getColValue("FECHA_CREAC")%></td>
                           <td width="15%">&nbsp;</td>
                           </tr>
                           <%=fb.hidden("codigo"+p,cdoEval.getColValue("CODIGO"))%>
							<% 
						      }
						   %>
       </table>
       </div>
       </div>
   </td>
</tr>
<tr class="TextRow02">
			<td colspan="5" align="right"><!--<a href="javascript:imprimir()">[ Imprimir ]</a>-->
			</td>
		</tr>
						<td align="center" width="5%"><%//=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Procedimiento")%>
						</td>
				 </tr>
                    
					<tr class="TextRow01">
						<td><cellbytelabel id="3">Forma de Solicitud</cellbytelabel> 
							&nbsp;&nbsp;<%=fb.radio("formaSolicitudX","P",(UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="4">Presencial</cellbytelabel>
							<%=fb.radio("formaSolicitudX","T",(!UserDet.getRefType().equalsIgnoreCase("M"))?true:false,viewMode,false,null,null,"onClick=\"javascript:setFormaSolicitud(this.value)\"")%> <cellbytelabel id="5">Telef&oacute;nica</cellbytelabel>	
							&nbsp;&nbsp;&nbsp;M&eacute;dico Solicitante<%=fb.textBox("nombreMedico",(UserDet.getRefType().equalsIgnoreCase("M"))?UserDet.getName():"",true, false,true,50,"","","")%>
							<%=fb.button("btnMed","...",true,viewMode,null,null,"onClick=\"javascript:showMedicList()\"","Médico")%>
						</td>
					</tr>
					<tr>
						<td width="100%" >
							<cellbytelabel>Descripci&oacute;n</cellbytelabel>
							<br><%=fb.textarea("descripcion",cdo1.getColValue("DESCRIPCION"),true,false,viewMode,60,4,2000,"","width:100%","")%></td>
						<td align="center" width="5%">&nbsp;<%//=fb.submit("rem"+code,"X",false,( (!code.trim().equals("0"))?false:true),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+code+")\"","Eliminar")%></td>
								<%=fb.hidden("remove"+code,code)%>
								<%=fb.hidden("usuario_creac",cdo1.getColValue("usuario_creac"))%>
								<%=fb.hidden("fecha_creac",cdo1.getColValue("fecha_creac"))%>
								<%=fb.hidden("usuario_modific",cdo1.getColValue("usuario_modif"))%>
								<%=fb.hidden("fecha_modific",cdo1.getColValue("fecha_modif")) %>
								<%//=fb.hidden("codigo",cdo.getColValue("CODIGO"))%>
								<%=fb.hidden("EKG",cdo1.getColValue("EKG"))%>
					</tr>


					<tr class="TextRow02" align="right">
						<td colspan="2">
				<%=fb.hidden("saveOption","O")%>
				
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
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
}//fin GET
//------------------------------- -----------------------------------
else
{			String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
			String baction = request.getParameter("baction");

					cdo = new CommonDataObject();
					cdo.setTableName("TBL_SAL_PROCEDIMIENTO_PACIENTE");
					
					cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
					
					cdo.addColValue("DESCRIPCION",request.getParameter("descripcion"));
					cdo.addColValue("USUARIO_CREAC",request.getParameter("usuario_creac"));
					cdo.addColValue("FECHA_CREAC",request.getParameter("fecha_creac"));
					cdo.addColValue("USUARIO_MODIF",(String) session.getAttribute("_userName"));
					cdo.addColValue("FECHA_MODIF",cDateTime);
					
					cdo.addColValue("FEC_NACIMIENTO", request.getParameter("dob"));
					cdo.addColValue("COD_PACIENTE",request.getParameter("codPac"));
					cdo.addColValue("SECUENCIA",request.getParameter("noAdmision"));
					cdo.addColValue("PAC_ID",request.getParameter("pacId"));
					cdo.addColValue("forma_solicitud",request.getParameter("formaSolicitud"));
					
					cdo.addColValue("medico",request.getParameter("medico"));		
					ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());		
					if(mode.equalsIgnoreCase("add")){
					  cdo.addColValue("USUARIO_CREAC",(String) session.getAttribute("_userName"));
					  cdo.addColValue("FECHA_CREAC",cDateTime); 	
					  cdo.addColValue("CODIGO",request.getParameter("code"));
					  cdo.addColValue("DESCRIPCION",request.getParameter("descripcion"));
					  cdo.addColValue("EKG",request.getParameter("EKG"));
					  cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision"));
					  cdo.setAutoIncCol("codigo");
		              cdo.addPkColValue("codigo","");
						
					  SQLMgr.insert(cdo);
					  code = SQLMgr.getPkColValue("CODIGO");
					
					}else{
						cdo.addColValue("USUARIO_CREAC",request.getParameter("usuario_creac"));
						cdo.addColValue("FECHA_CREAC",request.getParameter("fecha_creac"));						
						cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and secuencia="+request.getParameter("noAdmision")+" and codigo = "+code);
						SQLMgr.update(cdo);
					}
					
					
					ConMgr.clearAppCtx(null);
					
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

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=view&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&code=<%=code%>&desc=<%=desc%>&medico=<%=medico%>&from=<%=from%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>



