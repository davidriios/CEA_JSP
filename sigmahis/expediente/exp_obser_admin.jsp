<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iObservaciones" scope="session" class="java.util.Hashtable" />
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
String sql = "";
String change = request.getParameter("change");
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
 
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision"); 
String dob = request.getParameter("dob"); 
String codPac = request.getParameter("codPac"); 
String fp = request.getParameter("fp"); 
String tipo = request.getParameter("tipo"); 
String fg = request.getParameter("fg"); 
String fechaCita = request.getParameter("fechaCita"); 
String codCita = request.getParameter("codCita");
String exp = request.getParameter("exp");

if(fp==null) fp="";
if(fg==null) fg="";
String key = "";
int obserLastLineNo = 0;
if(tipo==null) tipo="E";
if(fechaCita==null) fechaCita="";
if(codCita==null) codCita="";
if(exp==null) exp="";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
String xtra = fg.trim().equals("EXP")?" order by tipo desc, secuencia ":" and tipo='"+tipo+"' order by secuencia asc ";
if (request.getMethod().equalsIgnoreCase("GET"))
{ 
	if (change == null)
	{			
		iObservaciones.clear();
		sql = "select 'V' status, to_char(fecha_nacimiento,'dd/mm/yyyy')dob , paciente, admision, secuencia, observacion, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy hh12:mi:ss am') fecha_creacion , usuario_modificacion, to_char(fecha_modificacion ,'dd/mm/yyyy hh12:mi:ss am')fecha_modificacion , estado,pac_id, tipo, decode(tipo,'A','ADMISION','E','EXPEDIENTE','F','FACTURACION','C','CXC') as tipo_desc,cod_motivo from tbl_adm_admision_nota_admin  where pac_id= "+pacId+" and admision ="+noAdmision+xtra;
		
		al = SQLMgr.getDataList(sql);
		for (int i=0; i<al.size(); i++)
		{
			cdo = (CommonDataObject) al.get(i);
			cdo.setKey(i);
			cdo.setAction("U");
			try
			{
				iObservaciones.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		if(!fg.trim().equals("EXP")){ 
		if (al.size() == 0)
		{
			if (!viewMode) mode = "add";
			cdo = new CommonDataObject();

			cdo.addColValue("secuencia","0");
			cdo.addColValue("estado","A");
			if(tipo.trim().equals("S"))cdo.addColValue("observacion","SE DETALLA SEGUN MOTIVO.");
			cdo.addColValue("status","A");
			cdo.addColValue("fecha_creacion",cDateTime);
			cdo.addColValue("fecha_modificacion",cDateTime);
			cdo.addColValue("usuario_creacion",UserDet.getUserName());
			cdo.addColValue("usuario_modificacion",UserDet.getUserName());
						
			cdo.setAction("I");
			cdo.setKey(iObservaciones.size() + 1);

			try
			{
				iObservaciones.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		else if (!viewMode) mode = "edit";}
	}//change=null
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
document.title = 'Observaciones Administrativas - '+document.title;
function doAction(){}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp"  flush="true">
  <jsp:param name="title" value='OBSERVACIONES ADMINISTRATIVAS'></jsp:param>
  <jsp:param name="displayCompany" value="n"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
 
<table align="center" width="99%" cellpadding="5" cellspacing="0">  
<tr>
	<td colspan="4" align="right">&nbsp;</td>
</tr>
<tr>
	<td class="TableBorder"><%if(!fg.trim().equals("EXP")){%>
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td colspan="4">
				<jsp:include page="../common/paciente.jsp" flush="true">
					<jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
					<jsp:param name="fp" value="expediente"></jsp:param>
					<jsp:param name="mode" value="view"></jsp:param>
					<jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
				</jsp:include>
			</td>
		</tr>
		</table><%}%>
		<table width="100%" cellpadding="1" cellspacing="1" class="TableBorderLightGray">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%> 
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("obserSize",""+iObservaciones.size())%>
<%=fb.hidden("obserLastLineNo",""+obserLastLineNo)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codPac",codPac)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("tipo",tipo)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fechaCita",fechaCita)%>
<%=fb.hidden("codCita",codCita)%>

    <tr class="TextRow02">
      <td colspan="7">&nbsp;</td>
    </tr>
    <tr class="TextHeader" align="center">
      <td width="70%"><cellbytelabel id="1"><%=(!tipo.trim().equals("S"))?"Observaciones":"Motivo"%></cellbytelabel></td>
	  <td width="10%"><cellbytelabel id="2">Usuario Creaci&oacute;n</cellbytelabel></td>
	  <td width="15%"><cellbytelabel id="3">Fecha Creaci&oacute;n</cellbytelabel></td>
      <td width="5%"><%if(!fg.trim().equals("EXP")){%><%=fb.submit("agregar","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Observaciòn")%><%}%></td>
    </tr>
<% 
String gTipo = "";
al = CmnMgr.reverseRecords(iObservaciones);	
for (int i=0; i<iObservaciones.size(); i++)
{
	 key = al.get(i).toString();		
	 cdo = (CommonDataObject) iObservaciones.get(key);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	  String style = (cdo.getAction().equalsIgnoreCase("D"))?" style=\"display:'none'\"":"";
%>
		<%=fb.hidden("remove"+i,"")%>
		<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
		<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
		<%=fb.hidden("usuario_modificacion"+i,cdo.getColValue("usuario_modificacion"))%>
		<%=fb.hidden("fecha_modificacion"+i,cdo.getColValue("fecha_modificacion"))%>
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>
		<%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
		<%=fb.hidden("status"+i,cdo.getColValue("status"))%>
		<%=fb.hidden("action"+i,cdo.getAction())%>
		<%=fb.hidden("key"+i,cdo.getKey())%>
		
	<% if (fg.trim().equals("EXP") && !gTipo.equals(cdo.getColValue("tipo"))){%>
		<tr class="TextHeader">
			<td colspan="4"><%=cdo.getColValue("tipo_desc")%></td>
		</tr>
	<%}%>	
   
    <tr class="<%=color%>" align="center"  <%=style%>>
      <td>
	  
	  <%=(!tipo.trim().equals("S"))?fb.textarea("observacion"+i,cdo.getColValue("observacion"),((cdo.getAction().equalsIgnoreCase("D")||fg.trim().equals("EXP"))?false:true),false,(viewMode || cdo.getColValue("status").trim().equals("V")),0,4,2000,"","width:100%",""):""%>
	  <%if(tipo.trim().equals("S")){%>
	  <%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
	  <%=fb.select("cod_motivo"+i,"1=PACIENTE LLEGA TARDE,2=MEDICO LLEGA TARDE,3=PEDIATRA LLEGA TARDE,4=ANESTESIóLOGO LLEGA TARDE,5=MEDICO Y ANESTESIóLOGO LLEGA TARDE,6=INSUMOS TARDE,7=BANDEJA TARDE,8=LIMPIEZA TARDE,9=ATRASADO POR URGENCIA PREVIA,10=ATRASADO POR CIRUGIA PREVIA",cdo.getColValue("cod_motivo"),true,false,false,0,"S")%>
	  <%}%>
	  
	  </td>
	  <td><%=cdo.getColValue("usuario_creacion")%></td>
	  <td><%=cdo.getColValue("fecha_creacion")%></td>
	  <td><%if(!fg.trim().equals("EXP")){%><%=fb.submit("rem"+i,"X",false,(viewMode || cdo.getColValue("status").trim().equals("V")),null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%><%}%></td>
    </tr>
    
<%
gTipo = cdo.getColValue("tipo");
} // for i
fb.appendJsValidation("if(error>0)doAction();");
%>
    <%if(!fg.trim().equals("EXP")){%><tr class="TextRow02">
      <td colspan="8" align="right">
        <cellbytelabel id="4">Opciones de Guardar</cellbytelabel>: 
        <%if(fp!=null && !fp.equals("admision")){%>
        <!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro--> 
        <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="5">Mantener Abierto</cellbytelabel> 
        <%}%>
        <%=fb.radio("saveOption","C",(fp!=null && fp.equals("admision")?true:false),viewMode,false)%><cellbytelabel id="6">Cerrar</cellbytelabel> 
        <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
        <%=fb.button("cancel","Cancelar",true,false,null,null,((tipo.trim().equals("S"))?"onClick=\"javascript:parent.hidePopWin(false);\"":"onClick=\"javascript:window.close()\""))%>
      </td>
    </tr><%}%>
<%=fb.formEnd(true)%>
    </table>
  </td>
</tr>
</table>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
<%
}//GET 
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("obserSize"));
	String itemRemoved = "";
	al.clear();
	iObservaciones.clear();
	for (int i=0; i<size; i++)
	{		
		cdo = new CommonDataObject();

		cdo.setTableName("tbl_adm_admision_nota_admin"); 
		cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision")+" and secuencia="+request.getParameter("secuencia"+i));  
		cdo.addColValue("paciente",request.getParameter("codPac"));
		cdo.addColValue("fecha_nacimiento", request.getParameter("dob"));
		cdo.addColValue("pac_id",request.getParameter("pacId"));
		cdo.addColValue("admision",request.getParameter("noAdmision"));
		cdo.addColValue("tipo",tipo);	  
		cdo.addColValue("fecha_registro",request.getParameter("fechaCita")); 
		cdo.addColValue("cod_cita",request.getParameter("codCita")); 
		if (request.getParameter("cod_motivo"+i) != null)cdo.addColValue("cod_motivo",request.getParameter("cod_motivo"+i)); 
		
		if (request.getParameter("secuencia"+i).equals("0")||request.getParameter("secuencia"+i).trim().equals(""))
		{
			cdo.setAutoIncCol("secuencia");
			cdo.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and admision="+request.getParameter("noAdmision"));
			cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));		
			cdo.addColValue("usuario_modificacion",request.getParameter("usuario_modificacion"+i));
			cdo.addColValue("fecha_modificacion",request.getParameter("fecha_modificacion"+i));	 
		}
		else
		{		
			cdo.addColValue("secuencia",request.getParameter("secuencia"+i));
			cdo.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i));
			cdo.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));		
			cdo.addColValue("usuario_modificacion",UserDet.getUserName());
			cdo.addColValue("fecha_modificacion",cDateTime);	 
		}

		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.addColValue("estado",request.getParameter("estado"+i));
		cdo.addColValue("status",request.getParameter("status"+i));
		
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
				iObservaciones.put(cdo.getKey(),cdo);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for
	
	if (!itemRemoved.equals(""))
	{	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&dob="+request.getParameter("dob")+"&codPac="+request.getParameter("codPac")+"&fp="+request.getParameter("fp")+"&fg="+request.getParameter("fg")+"&tipo="+request.getParameter("tipo"));
		return;
	}		

	if (baction.equals("+"))//Agregar
	{
		cdo = new CommonDataObject();

		cdo.addColValue("secuencia","0");
		cdo.addColValue("status","A");
		cdo.addColValue("estado","A");
		cdo.addColValue("fecha_creacion",cDateTime);
		cdo.addColValue("fecha_modificacion",cDateTime);
		cdo.addColValue("usuario_creacion",UserDet.getUserName());
		cdo.addColValue("usuario_modificacion",UserDet.getUserName());
		if(tipo.trim().equals("S"))cdo.addColValue("observacion","SE DETALLA SEGUN MOTIVO.");
	
		cdo.setAction("I");
		cdo.setKey(iObservaciones.size() + 1);
		try
		{
			iObservaciones.put(cdo.getKey(),cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&dob="+request.getParameter("dob")+"&codPac="+request.getParameter("codPac")+"&fp="+request.getParameter("fp")+"&fg="+request.getParameter("fg")+"&tipo="+request.getParameter("tipo")+"&codCita="+request.getParameter("codCita")+"&fechaCita="+request.getParameter("fechaCita"));
		return;
	}	

	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_admision_nota_admin");  
			cdo.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and tipo='"+tipo+"'"); 						
			cdo.setKey(iObservaciones.size() + 1);
			cdo.setAction("I");
			al.add(cdo); 
		}
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		 SQLMgr.saveList(al,true);
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
		if(fp!=null && (fp.equals("admision")||fp.equals("citas"))){
		if(fp.equals("citas")){
%>
		 parent.hidePopWin(false);
		<%}else{%>
		window.close();
		<%}} else {%>
	parent.doRedirect(0);
		<%}%>
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&dob=<%=dob%>&codPac=<%=codPac%>&tipo=<%=tipo%>&fg=<%=fg%>&fechaCita=<%=fechaCita%>&codCita=<%=codCita%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
















