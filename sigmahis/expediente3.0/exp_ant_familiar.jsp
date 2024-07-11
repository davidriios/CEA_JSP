<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();

boolean viewMode = false;
String sql = "", sqlTitle="";
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}

	sql = "select a.codigo as cod_antecedente, a.descripcion, nvl(b.valor,' ') as valor, nvl(b.observacion,' ') as observacion,decode(b.antecedente,null,'I','U') action,to_char(b.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')fecha_creacion,b.usuario_creacion, a.es_default, (select count(*) from tbl_sal_antecedente_familiar b, tbl_sal_diagnostico_familiar a where b.pac_id = "+pacId+" and b.admision = "+noAdmision+" and a.codigo = b.antecedente and a.es_default <> 'S') tot_saved, 1 grupo from tbl_sal_diagnostico_familiar a, tbl_sal_antecedente_familiar b where a.codigo=b.antecedente(+) and b.pac_id(+)="+pacId+ " and nvl(b.admision,"+noAdmision+") = "+noAdmision+" order by a.orden";
	al = SQLMgr.getDataList(sql);
%>
		<!--Bienvenido a CELLBYTE Expediente Electronico V3.0 Build 1.4 BETA-->
		<!--Bootstrap 3, JQuery UI Based, HTML5 y {LESS}-->
		<!--Para mas Informacion leer (info_v3.txt)-->
		<!--Done by. eduardo.b@issi-panama.com-->
		<!DOCTYPE html>
		<html lang="en">
		<!--comienza el head-->
		<head>
		<meta charset="utf-8">
		<title>Expediente Cellbyte</title>

		<%@ include file="../common/nocache.jsp"%>
		<%@ include file="../common/header_param_bootstrap.jsp"%>
		<script>
document.title = 'EXPEDIENTE - Antecedente Familiar - '+document.title;
function doAction(){newHeight();}
function isChecked(k){/*eval('document.form0.observacion'+k).readOnly = !eval('document.form0.valor'+k).checked;if (eval('document.form0.valor'+k).checked)eval('document.form0.observacion'+k).className = 'form-control input-sm FormDataObjectEnabled';else eval('document.form0.observacion'+k).className = 'form-control input-sm FormDataObjectDisabled';*/}
function printExp(){abrir_ventana("../expediente3.0/print_exp_seccion_7.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>");}

$(function(){
				// init tooltip
				$('[data-toggle="tooltip"]').tooltip();

				$(".grupo-2").not(".default-2").click(function(e){
						var _default = $("input:checkbox[data-default-2='S']");
						if (_default.is(":checked")) {
							 e.preventDefault();
							 return false;
						} else {
								var self = $(this);
								var i = self.data('i');
								ctrlFields(i, self.is(":checked"));
						}
				});

				$(".grupo-1").not(".default-1").click(function(e){
						var _default = $("input:checkbox[data-default-1='S']");
						if (_default.is(":checked")) {
							 e.preventDefault();
							 return false;
						} else {
								var self = $(this);
								var i = self.data('i');
								ctrlFields(i, self.is(":checked"));
						}
				});

				$(".default-1, .default-2").click(function(){
						var self = $(this);
						var i = self.data('i');
						var grupo = self.data('grupo');
						if (this.checked) {
								$(".grupo-"+grupo).not(self).prop("checked", false).each(function(){
										ctrlFields($(this).data('i'), $(this).is(":checked"));
								});
								$(".field-"+grupo).not(self).prop("readOnly", true).val("");
								ctrlFields(i, true)
						} else ctrlFields(i, false)
				});
		});


function ctrlFields(i, isChecked) {
			var action = $("#action_tmp"+i).val();
			if (isChecked) {
					$("#observacion"+i).prop("readOnly", false);
					$("#action"+i).val(action);
			} else {
					$("#observacion"+i).prop("readOnly", true).val("");
					if (action == 'U') $("#action"+i).val("D");
			}
}
</script>

		</head>
		<!--termina el head-->

		<!--comienza el cuerpo del sitio-->
		<body class="body-form">

				<!-----------------------------------------------------------------/INICIO Fila de Peneles/--------------->
		<!--INICIO de una fila de elementos-->
		<div class="row">
		<%fb = new FormBean2("form0",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("size",""+al.size())%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("desc",desc)%>
		<!--INICIO de una fila de elementos-->

		<div class="table-responsive" data-pattern="priority-columns">
				<div class="headerform">
		<!--tabla de boton imprimir-->
		<table cellspacing="0" class="table pull-right table-striped table-custom-1">
		<tr>
		<td><%=fb.button("btnPrint","Imprimir",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:printExp()\"")%></td>
		</tr>
		</table></div>
		<!--fin tabla de boton imprimir-->


		<!--cuerpo del formulario aqui-->
		<!--el class de este sitio siempre debe tener el class="table table-small-font table-bordered table-striped"-->
		<table cellspacing="0" class="table table-small-font table-bordered table-striped">
		<thead>
		<tr class="bg-headtabla" >
				<th>Diagnosticos</th>
				<th>Si</th>
				<th>Observación</th>
		</tr>
		</thead>

		<tbody>
		<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("antecedente"+i,cdo.getColValue("cod_antecedente"))%>
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("action_tmp"+i,cdo.getColValue("action"))%>
		<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		<tr class="<%=color%>">
			<th><%=cdo.getColValue("descripcion")%></th>
			<td align="center">
			<%=fb.checkbox("valor"+i,"S",(cdo.getColValue("valor").equalsIgnoreCase("S")|| (cdo.getColValue("es_default").equalsIgnoreCase("S")&&cdo.getColValue("tot_saved","0").equals("0"))),viewMode,"grupo-"+cdo.getColValue("grupo"," ")+(cdo.getColValue("es_default"," ").equalsIgnoreCase("S")?" default-"+cdo.getColValue("grupo"," "):""),null,"onClick=\"javascript:isChecked("+i+")\"", null, " data-default-"+cdo.getColValue("grupo")+"='"+cdo.getColValue("es_default")+"' data-i="+i+" data-grupo="+cdo.getColValue("grupo"," "))%>

			</td>

			<td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,viewMode||(!cdo.getColValue("valor").equalsIgnoreCase("S")),50,2,2000,"form-control input-sm field-"+cdo.getColValue("grupo"," "),"width='100%'",null)%>
			</td>
		</tr>
<%
}
%>

		 </tbody>
		</table>


		<!--tabla de boton botones guardar cancelar-->
		 <div class="footerform">
		<table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
		<tr>
			<td>
				<%=fb.hidden("saveOption","O")%>
				<%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,null)%>
				<%//=fb.button("cancel","Cancelar",false,false,"btn btn-inverse btn-sm",null,"onClick=\"javascript:parent.doRedirect(0)\"")%>
			</td>
		</tr>
				 </table>  </div>
		<!--tabla de boton botones guardar cancelar-->

		</div>

		<!-- FIN contenido del sitio aqui-->
		<%=fb.formEnd(true)%>
		</div>
		<!-- FIN contenido del sitio aqui-->

		<!-- FIN Cuerpo del sitio -->
		</body>
		<!-- FIN Cuerpo del sitio -->


		</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size= Integer.parseInt(request.getParameter("size"));
	al.clear();

	for (int i=0; i<size; i++)
	{
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_antecedente_familiar");
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and antecedente ="+request.getParameter("antecedente"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));

		System.out.println(":::::::::::::::::::::::::::::::::::::::::::: "+request.getParameter("valor"+i));

		if (request.getParameter("valor"+i) != null && request.getParameter("valor"+i).equalsIgnoreCase("S"))
		{

			if(request.getParameter("action"+i) != null && request.getParameter("action"+i).trim().equals("U")){
								cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and antecedente ="+request.getParameter("antecedente"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
								cdo.setAction("U");
								cdo.addColValue("fecha_modificacion",cDateTime);
								cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
						}
						else {
								cdo.setAction("I");
								cdo.addColValue("fec_nacimiento",request.getParameter("dob"));
								cdo.addColValue("cod_paciente",request.getParameter("codPac"));
								cdo.addColValue("pac_id",request.getParameter("pacId"));
								cdo.addColValue("admision",request.getParameter("noAdmision"));
								cdo.addColValue("fecha_creacion",cDateTime);
								cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
						}


			cdo.addColValue("antecedente",request.getParameter("antecedente"+i));
			cdo.addColValue("valor","S");
			cdo.addColValue("observacion",request.getParameter("observacion"+i));

			al.add(cdo);
		} else {
				if (request.getParameter("action"+i).trim().equalsIgnoreCase("D")){
						cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and antecedente ="+request.getParameter("antecedente"+i)+" and nvl(admision,"+request.getParameter("noAdmision")+") = "+request.getParameter("noAdmision"));
						cdo.setAction("D");
						al.add(cdo);
				}
			}
	}

	if (al.size() == 0)
	{
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_sal_antecedente_familiar");
		cdo.setWhereClause("pac_id = "+request.getParameter("pacId"));
		cdo.setAction("I");
		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true);
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
}
</script>
</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>
