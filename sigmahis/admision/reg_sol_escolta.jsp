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
<jsp:useBean id="iEsp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEsp" scope="session" class="java.util.Vector" />
<jsp:useBean id="iSoc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSoc" scope="session" class="java.util.Vector" />
<jsp:useBean id="iUbi" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vUbi" scope="session" class="java.util.Vector" />
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

CommonDataObject escSolCdo = new CommonDataObject();

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String id = (request.getParameter("id")==null?"0":request.getParameter("id"));
String sql = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String pacId = (request.getParameter("pacId")==null?"":request.getParameter("pacId"));
String noAdmision = (request.getParameter("noAdmision")==null?"":request.getParameter("noAdmision"));
String fromBed = (request.getParameter("fromBed")==null?"":request.getParameter("fromBed"));
String fromCDS = (request.getParameter("fromCDS")==null?"":request.getParameter("fromCDS"));
String cdsAdmDesc = (request.getParameter("cdsAdmDesc")==null?"":request.getParameter("cdsAdmDesc"));
String admCategory = (request.getParameter("admCategory")==null?"":request.getParameter("admCategory"));
String toCdsDesc = ( request.getParameter("toCdsDesc") == null?"":request.getParameter("toCdsDesc") );

if (mode == null) mode = "add";

if (escSolCdo == null) escSolCdo = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";

	}else{
	    if (id.trim().equals("0")) throw new Exception("Por favor contacte un administrador [ID no encontrado]");

		sql = "select id, escolta_id,pac_id,admision,del_cds,al_cds,cat_admision,cama_origen,estado,fecha_ini_sol,fecha_fin_sol,usuario_creacion,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion,fecha_modificacion,usuario_modificacion,cama_destino, observ, observacion from tbl_sal_sol_escolta where id = "+id+"";

		escSolCdo = SQLMgr.getData(sql);
    }

System.out.println(".........................GET thebrain> "+mode+ " "+id);

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Escolta -  Edición - '+document.title;

function addData(opt){
	switch(opt){
		case 'ESCORT': abrir_ventana('../common/search_escort.jsp?fp=escort'); break; //Escorta
		case 'CDS': abrir_ventana('../common/search_centro_servicio.jsp?fp=escort'); break; //CDS
		case 'CAMA': abrir_ventana('../common/search_cama.jsp?fp=escort'); break; //CDS
		default: CBMSG.warning();
	}

}
function doAction(){_ctrlToCds();}

function _ctrlToCds(){
   if(document.getElementById("ctrlToCds").checked){
	   	 document.getElementById("observacion").readOnly = false;
	   	 document.getElementById("observacion").className = 'FormDataObjectEnabled';
   }else{
      	//console.log("unchecked");
      	document.getElementById("observacion").value = "";
   	  	document.getElementById("observacion").readOnly = true;
   	  	document.getElementById("observacion").className = 'FormDataObjectDisabled';
   }
}
function canSubmit(){
 	if (document.getElementById("escort").value==""){
		CBMSG.warning('Por favor seleccione une Escolta Anfitrión'); return false;
	}else
    if(document.getElementById("ctrlToCds").checked){
	   	if(document.getElementById("observacion").value == ""){
	   	   CBMSG.warning('Por favor indique porque el área de destino no es necesario!');return false;
	   	}
    }
   else{
   	  if (document.getElementById("toCDS").value==""){
		 CBMSG.warning('Por favor indique en que área va a estar el paciente!');return false;
      }
   }
   return true;
}
function _doSubmit(){
	if(canSubmit()){document.form0.submit();
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISIÓN - MANTENIMIENTO - ESCOLTA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("usuarioCreacion",escSolCdo.getColValue("usuario_creacion"))%>
				<%=fb.hidden("fechaCreacion",escSolCdo.getColValue("fecha_creacion"))%>
				<%=fb.hidden("id",id)%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="5%">Anfitri&oacute;n</td>
								<td width="10%"><%=fb.textBox("escort",escSolCdo.getColValue("escolta_id"),true,false,true,5,5,null,null,"")%>
									&nbsp;&nbsp;&nbsp;
									<%=fb.button("btnAdd","...",true,false,null,null,"onClick=\"javascript:addData('ESCORT')\"")%>
								</td>
								<td width="40%">&Aacute;rea Origen Paciente&nbsp;&nbsp;&nbsp;
									<%=fb.textBox("fromCDS",fromCDS,false,false,true,5,5,null,null,"")%>
									<%=fb.textBox("cdsAdmDesc",cdsAdmDesc,false,false,true,40,100,null,null,"")%>
								</td>
								<td width="45%">&Aacute;rea Destino&nbsp;&nbsp;&nbsp;
									<%=fb.textBox("toCDS",escSolCdo.getColValue("al_cds"),false,false,true,5,5,null,null,"")%>
									<%=fb.textBox("toCdsDesc",toCdsDesc,false,false,true,25,100,null,null,"")%>
									&nbsp;&nbsp;&nbsp;
									<%=fb.button("btnAdd","...",true,false,null,null,"onClick=\"javascript:addData('CDS')\"")%>
									&nbsp;&nbsp;&nbsp;No aplica
									<%=fb.checkbox("ctrlToCds","",(escSolCdo.getColValue("observacion")!=null && !escSolCdo.getColValue("observacion").trim().equals("")),false,null,null,"onClick=\"javascript:_ctrlToCds()\"")%>
								</td>
							</tr>

							<tr class="TextRow01">
								<td colspan="4">
									<table width="100%" cellpadding="2" cellspacing="1">
										 <tr class="TextRow01">
										 	<td width="25%">Cama Origen Paciente</td>
										 	<td width="5%"><%=fb.textBox("fromBed",fromBed,false,false,true,5,10,null,null,"")%></td>
										 	<td width="10%">Cama Destino</td>
										 	<td width="30%"><%=fb.textBox("toBed",escSolCdo.getColValue("cama_destino"),false,false,true,10,10,null,null,"")%>
										 		&nbsp;&nbsp;&nbsp;
												<%=fb.button("btnAdd","...",true,false,null,null,"onClick=\"javascript:addData('CAMA')\"")%>
										 	</td>
										 	<td width="30%">Categor&iacute;a
										 		<%=fb.select(ConMgr.getConnection(),"select codigo, descripcion, codigo from tbl_adm_categoria_admision","admCategory",admCategory,false,false,0,"Text10",null,null,null,"")%>
										 	</td>
										 </tr>
										 <tr class="TextRow01" id="obs">
										 	<td>Observaci&oacute;n</td>
										 	<td colspan="2">
												<%=fb.textarea("observ",escSolCdo.getColValue("observ"),false,false,false,50,2,1000)%>
										 	</td>
										 	<td align="right">¿Porque no aplica?</td>
										 	<td>
										 		<%=fb.textarea("observacion",escSolCdo.getColValue("observacion"),false,false,true,50,2,1000)%>
										 	</td>
										 </tr>
									</table>
								<td>
							</tr>


				<tr class="TextRow02">
					<td align="right" colspan="4">
						<!--<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%//=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%//=fb.radio("saveOption","O")%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%//=fb.radio("saveOption","C",true,false,false)%><cellbytelabel>Cerrar</cellbytelabel>-->
						<%=fb.button("send","Guardar",true,false,null,null,"onClick=\"javascript:_doSubmit()\"")%>
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

		System.out.println("thebrain>:::::::::::::::::::::::::::::::::::::::::::::::::::::: saveOption = "+request.getParameter("observacion"));

		CommonDataObject cdoSolEscort = new CommonDataObject();

  		cdoSolEscort.setTableName("tbl_sal_sol_escolta");

		cdoSolEscort.addColValue("escolta_id",request.getParameter("escort"));
		cdoSolEscort.addColValue("pac_id",request.getParameter("pacId"));
		cdoSolEscort.addColValue("admision",request.getParameter("noAdmision"));
		cdoSolEscort.addColValue("del_cds",request.getParameter("fromCDS"));
		cdoSolEscort.addColValue("al_cds",request.getParameter("toCDS"));
		cdoSolEscort.addColValue("cat_admision",request.getParameter("admCategory"));
		cdoSolEscort.addColValue("cama_origen",request.getParameter("fromBed"));
		cdoSolEscort.addColValue("estado","P");
		cdoSolEscort.addColValue("fecha_ini_sol",cDate);
		cdoSolEscort.addColValue("fecha_fin_sol",cDate);
		cdoSolEscort.addColValue("cama_destino",request.getParameter("toBed"));

		cdoSolEscort.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdoSolEscort.addColValue("fecha_modificacion",cDate);

		String observ = (request.getParameter("observacion")==null?"":request.getParameter("observacion"));

		cdoSolEscort.addColValue("observacion",IBIZEscapeChars.forSingleQuots(observ));
		cdoSolEscort.addColValue("observ",IBIZEscapeChars.forSingleQuots(request.getParameter("observ")));

	  if (mode.equalsIgnoreCase("add")){

	  		cdoSolEscort.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdoSolEscort.addColValue("fecha_creacion",cDate);

			cdoSolEscort.setAutoIncCol("id");

			SQLMgr.insert(cdoSolEscort);
			id = cdoSolEscort.getAutoIncCol();
			//SQLMgr.setErrCode("1");
		}

		else if (mode.equalsIgnoreCase("edit"))
		{
			System.out.println(".........................thebrain> "+mode+ " "+id);
			cdoSolEscort.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"));
		    cdoSolEscort.addColValue("fecha_creacion",request.getParameter("fechaCreacion"));

			cdoSolEscort.setWhereClause("id="+request.getParameter("id")+"");

			SQLMgr.update(cdoSolEscort);
		}
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
	//window.opener.location = '<%=request.getContextPath()%>/admision/escolta_list.jsp';
	window.close();
<%

} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>