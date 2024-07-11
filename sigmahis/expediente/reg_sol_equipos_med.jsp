<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iEQM" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEQM" scope="session" class="java.util.Vector" />
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

CommonDataObject solCdo = new CommonDataObject();

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String id = (request.getParameter("id")==null?"0":request.getParameter("id"));
String sql = "";
String key = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String pacId = (request.getParameter("pacId")==null?"":request.getParameter("pacId"));
String admRoot = (request.getParameter("admRoot")==null?"":request.getParameter("admRoot"));
String compania = (String) session.getAttribute("_companyId");
String change = request.getParameter("change");
String solDevolucion = request.getParameter("solDevolucion");
String cds = request.getParameter("cds");
boolean viewMode = false;
if (mode == null) mode = "add";
if (solCdo == null) solCdo = new CommonDataObject();
String estadoData = "";
String categoria = "";
String noAdmision = (request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision"));

int hasSol = CmnMgr.getCount("select count(codigo) from tbl_inv_sol_equip_med where estado in('T','P') and compania = "+compania+" and pac_id = "+pacId+" and admision_corte = "+admRoot);
if (request.getMethod().equalsIgnoreCase("GET"))
{



 if (pacId.trim().equals("") || noAdmision.trim().equals("")) throw new Exception("Por favor contacte un administrador [Paciente no encontrado]");

	if (change==null){

		  iEQM.clear();
		  vEQM.clear();

		  sql = "select decode(estado,'P','U','')action,decode(estado,'T',1,'P',1,'E',2,'D',3,'R',4)orden, codigo, no_equipo,pac_id,admision,estado,usuario_creacion,usuario_modificacion, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion,to_char(fecha_entrega,'dd/mm/yyyy hh12:mi:ss am')fecha_entrega, to_char(fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') fecha_modificacion,cds,comentarios, cat_equipo,to_char(fecha_devolucion,'dd/mm/yyyy hh12:mi:ss am') fecha_devolucion from tbl_inv_sol_equip_med where pac_id = "+pacId+" and admision_corte = "+admRoot+" and compania = "+compania+" order by 2 asc,fecha_creacion desc";

		  al = SQLMgr.getDataList(sql);

		  for (int i=0; i<al.size(); i++){
			CommonDataObject cdo = (CommonDataObject) al.get(i);

			cdo.setKey(i);
			cdo.setAction(cdo.getColValue("action"));

			try
			{
				iEQM.put(cdo.getKey(), cdo);
				vEQM.addElement(cdo.getColValue("codigo"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		 }
	} //change = null
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Expediente -  Equipos Medicos- '+document.title;
function addData(opt){
    var curSelEqui = document.getElementById("equipo").value;
	switch(opt){case 'EQM': abrir_ventana('../common/sel_equipos_como_dato.jsp?fp=equipos_medicos&curSelEqui='+curSelEqui); break; //Equipos médicos
	default: alert(2);}}
function doAction(){<%if(hasSol>0){%>alert('HAY SOLICITUDES DE EQUIPOS EN ESTADO:  TEMPORAL/PENDIENTE!!!!!');<%}%>}
function canSubmit(){return true;}
function _doSubmit(formName,bAction){setBAction(formName,bAction);if(form0Validation()){if(canSubmit()) document.form0.submit();}}
function checkSol(value,codItem)
{
 if(codItem =='0'){
var cantSol = getDBData('<%=request.getContextPath()%>','count(*)','tbl_inv_sol_equip_med','pac_id=<%=pacId%> and admision=<%=noAdmision%> and estado in(\'T\',\'P\') and cat_equipo ='+value,''); if(parseInt(cantSol)>0)alert('Hay Solicitudes de equipo de la Categoria Seleccionada en estado TEMPORAL/PENDIENTE  = '+cantSol);}

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="EXPEDIENTE - TRANSACCIONES - EXPEDIENTE CLINICO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
							<tr class="TextPanel">
								<td colspan="2">Paciente</td>
							</tr>
							<tr>
								<td colspan="2">
								   <jsp:include page="../common/paciente.jsp" flush="true">
										<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
										<jsp:param name="fp" value="expediente"></jsp:param>
										<jsp:param name="mode" value="view"></jsp:param>
										<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
									</jsp:include>
								</td>
							</tr>
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("EQMSize",""+iEQM.size())%>
				<%=fb.hidden("admRoot",admRoot)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("codigo",id)%>
				<%=fb.hidden("cds",cds)%>
				<tr>
					<td colspan="2">
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow02"><td colspan="8">&nbsp;</td></tr>
							<tr class="TextPanel">
								<td colspan="8">Solicitud de equipos m&eacute;dicos</td>
							</tr>

							<tr class="TextPanel">
								<td width="4%">No.</td>
								<td width="19%">Categoria</td>
								<td width="10%">Estado</td>
								<td width="29%">Comentario</td>
								<td width="12%">Fecha Solicitud</td>
								<td width="12%">Fecha Entrega</td>
								<td width="12%">Fecha Devolucion</td>
								<td width="2%"><%=fb.submit("btnaddSol","+",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Solicitud")%>&nbsp;</td>
							</tr>




						<%
						al = CmnMgr.reverseRecords(iEQM);
						for (int i=0; i<iEQM.size(); i++)
						{
						  key = al.get(i).toString();
						  CommonDataObject cdo = (CommonDataObject) iEQM.get(key);
						  String display = " style='display:none;'";
						  boolean modeViewReg = false;
						  estadoData  = "";
						  if (cdo.getColValue("estado").equals("E")||cdo.getColValue("estado").equals("R")||cdo.getColValue("estado").equals("C")||cdo.getColValue("estado").equals("D")){estadoData += ",E=ENTREGADO,R=RECIBIDO,C=CANCELADO,D=DEVUELTO";modeViewReg=true;}
						  //else if (cdo.getColValue("estado").equals("C"))estadoData = ",C=CA";
						  if (cdo.getColValue("codigo").equals("0")) estadoData += "P=PENDIENTE"; else if (!cdo.getColValue("codigo").equals("0")&&(cdo.getColValue("estado").equals("T")||cdo.getColValue("estado").equals("P"))) estadoData = "P=PENDIENTE,C=CANCELADO";

						%>

						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("key"+i,cdo.getKey())%>
						<%=fb.hidden("action"+i,cdo.getAction())%>
						<%=fb.hidden("id"+i,cdo.getColValue("codigo"))%>
						<%=fb.hidden("usuarioCreacion"+i,cdo.getColValue("usuario_creacion"))%>
						<%=fb.hidden("fechaCreacion"+i,cdo.getColValue("fecha_creacion"))%>
						<%=fb.hidden("fecha_entrega"+i,cdo.getColValue("fecha_entrega"))%>
						<%=fb.hidden("fecha_devolucion"+i,cdo.getColValue("fecha_devolucion"))%>
						<%=fb.hidden("admision"+i,cdo.getColValue("admision"))%>

						<%=fb.hidden("cds"+i,cdo.getColValue("cds"))%>
						<%if(!cdo.getAction().equalsIgnoreCase("D")){%>


						    <tr class="TextRow01">
								<td><%=fb.textBox("codigo"+i,cdo.getColValue("codigo"),false,false,true,5,5,null,null,"")%></td>
								<td><%=fb.select(ConMgr.getConnection(), "select codigo,nombre from tbl_inv_cat_eq_comodatos where compania = "+compania+((!mode.trim().equals("view"))?" and estado = 'A'":"")+" order by orden asc", "categoria"+i, cdo.getColValue("cat_equipo"),false,(viewMode||modeViewReg),0,"Text10","","onChange=\"javascript:checkSol(this.value,"+cdo.getColValue("codigo")+")\"")%></td>
								<td><%=fb.select("estado"+i,estadoData,cdo.getColValue("estado"),false,(viewMode||modeViewReg),0,"","Text10","")%></td>
								<td><%=fb.textarea("comentario"+i,cdo.getColValue("comentarios"),true,false,(viewMode||modeViewReg),100,2,1000,"","width:100%","")%></td>
								<td><%=cdo.getColValue("fecha_creacion")%></td>
								<td><%=cdo.getColValue("fecha_entrega")%></td>
								<td><%=cdo.getColValue("fecha_devolucion")%></td>
								<td>&nbsp;<%=(cdo.getAction().equalsIgnoreCase("I"))?fb.submit("rem"+i,"X",true,(viewMode||modeViewReg),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Solicitud"):""%></td>
							</tr>


						<%
						} // not deleting
						} //for
						%>



				<tr class="TextRow02">
					<td align="right" colspan="8">
						<cellbytelabel id="15">Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="17">Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="18">Cerrar</cellbytelabel>
						<%=fb.button("send","Guardar",true,viewMode,null,null,"onClick=\"javascript:_doSubmit('"+fb.getFormName()+"',this.value)\"")%>
						<%//=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
				<%=fb.formEnd(true)%>

		</table>

	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
		String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
		String baction = request.getParameter("baction");

		int size = 0;
		if (request.getParameter("EQMSize") != null) size = Integer.parseInt(request.getParameter("EQMSize"));
		String itemRemoved = "";

		al.clear();
		iEQM.clear();
		vEQM.clear();
		int lineNo = 0;

		for (int i=0; i<size; i++)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_inv_sol_equip_med");
			cdo.setWhereClause("compania = "+compania+" and codigo = "+request.getParameter("id"+i));
			if(request.getParameter("id"+i).trim().equals("0"))
			{
				cdo.setAutoIncCol("codigo");
				cdo.addPkColValue("codigo","");
			}
			cdo.addColValue("codigo",request.getParameter("id"+i));
			cdo.addColValue("pac_id",request.getParameter("pacId"));
			cdo.addColValue("compania",compania);
			cdo.addColValue("estado",request.getParameter("estado"+i));
			cdo.addColValue("admision",request.getParameter("admision"+i));
			cdo.addColValue("admision_corte",request.getParameter("admRoot"));
			cdo.addColValue("comentarios",request.getParameter("comentario"+i));
			cdo.addColValue("cds",request.getParameter("cds"+i));
			cdo.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"+i));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",request.getParameter("fechaCreacion"+i));
			cdo.addColValue("fecha_modificacion",cDate);
			cdo.addColValue("cat_equipo",request.getParameter("categoria"+i));
			cdo.addColValue("fecha_entrega",request.getParameter("fecha_entrega"+i));
			cdo.addColValue("fecha_devolucion",request.getParameter("fecha_devolucion"+i));
			cdo.setKey(i);
			cdo.setAction(request.getParameter("action"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
			{
				itemRemoved = cdo.getKey();
				if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");//if it is not in DB then remove it
				else cdo.setAction("D");
			}

			if (!cdo.getAction().equalsIgnoreCase("X"))
			{
				try
				{
					iEQM.put(cdo.getKey(),cdo);
					vEQM.add(cdo.getColValue("codigo"));
					al.add(cdo);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}

		if (!itemRemoved.equals(""))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode=edit&id="+id+"&cds="+cds+"&pacId="+pacId+"&admRoot="+admRoot+"&noAdmision="+noAdmision);
			return;
		}


		if (baction != null && baction.equals("+"))
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.addColValue("codigo","0");
			cdo.addColValue("pac_id",pacId);
			cdo.addColValue("admision",noAdmision);
			cdo.addColValue("admision_corte",admRoot);
			cdo.addColValue("cds",cds);
			cdo.addColValue("estado","");
			cdo.addColValue("comentarios","");
			cdo.addColValue("fecha_creacion",cDate);
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion",cDate);
			cdo.addColValue("cat_equipo","");
			cdo.addColValue("fecha_entrega","");
			cdo.addColValue("fecha_devolucion","");

			cdo.setAction("I");
			cdo.setKey(iEQM.size()+1);

			iEQM.put(cdo.getKey(),cdo);

			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode=edit&id="+id+"&cds="+cds+"&pacId="+pacId+"&admRoot="+admRoot+"&noAdmision="+noAdmision);
			return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_inv_sol_equip_med");
			cdo.setWhereClause("codigo = '"+id+"' and compania = "+compania);
			cdo.setAction("I");
			al.add(cdo);
		}
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
<%
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
	window.close();
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&id=<%=id%>&pacId=<%=pacId%>&admRoot=<%=admRoot%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>