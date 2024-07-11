<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.inventory.PDTArchive"%>
<%@ page import="issi.inventory.PDTArchiveConf"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="PDTA" scope="page" class="issi.inventory.PDTArchive" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
PDTA.setConnection(ConMgr);

ArrayList al = new ArrayList();	
String sql = "";
String mode = "";
String archivoId = "";
String dispoWhere = "";
String cCompany = (String)session.getAttribute("_companyId");
String cUserName = (String)session.getAttribute("_userName");

String[] pdtP = {};

String barCodePos = "";
String anaquelPos = "";
String qtyPos = "";
String separator = "";
String fechaConteo = "";

cdo = SQLMgr.getData("select get_sec_comp_param("+cCompany+",'INV_PDT_COL_POS') as pdt_params from dual");
String pdtParams = cdo==null?";;;":cdo.getColValue("pdt_params");

try{
	pdtP = pdtParams.split(";");
    barCodePos = pdtP[0];
    anaquelPos = pdtP[1];
    qtyPos = pdtP[2];
    separator = pdtP[3];
}catch(Exception e){
  barCodePos = "0";
  anaquelPos = "1";
  qtyPos = "2";
  separator = "|";
  System.out.println(":::::::::::::::::::::::::: Whoops, looks like something went wrong with the definition of the pdt parameters. "+e);
  e.printStackTrace();
}

separator = separator.toLowerCase();

String actionText = "";
String status = "";

Hashtable ht = null;

PDTArchiveConf conf = new PDTArchiveConf();

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
{
	ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("docs.pdtfiles"),20,true);
	mode = (String) ht.get("mode");
	archivoId = (String) ht.get("archivoId");
	dispoWhere = (String) ht.get("dispoWhere");
	fechaConteo = (String) ht.get("fechaConteo");
}else{
 	mode = request.getParameter("mode");
	archivoId=request.getParameter("archivoId");
	dispoWhere=request.getParameter("dispoWhere");
	fechaConteo=request.getParameter("fechaConteo");
}	

if (mode == null) mode = "add";
if (archivoId == null) archivoId  = "0";
if (dispoWhere == null) dispoWhere  = "I";
if (fechaConteo == null) fechaConteo = "";
String fileRoot = java.util.ResourceBundle.getBundle("path").getString("docs.pdtfiles")+"/"; 

int alreadyLoaded = 0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	XMLCreator xml = new XMLCreator(ConMgr);
	
	xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+java.io.File.separator+"anaqueles_x_compania"+UserDet.getUserId()+".xml","select * from (select cod_anaquel as value_col, cod_anaquel||' - '||descripcion as label_col, compania||'@'||codigo_almacen as key_col  from tbl_inv_anaqueles_x_almacen ana where compania = "+cCompany+" and cod_anaquel is not null union all select '-99' as value_col, -99||' - SIN ANAQUEL' as label_col, compania||'@'||codigo_almacen as key_col  from tbl_inv_almacen ana where compania = "+cCompany+" ) z order by 2 asc");
	
	if (mode.equalsIgnoreCase("add")){
		cdo = (CommonDataObject) SQLMgr.getData("select nvl(max(id),0)+1 as id, nvl(get_sec_comp_param("+cCompany+",'INV_CONTEO_DISPO'),'I') dispo_where from tbl_inv_pdt_archivo where company_id = "+cCompany);
		archivoId = cdo.getColValue("id");
		dispoWhere = cdo.getColValue("dispo_where");
		cdo.addColValue("status", "");
		
		actionText = "Pre Cargar";
	}else{
		if (archivoId.trim().equals("")) throw new Exception("El id del achivo PDT es inválido!");
		
		sql = "SELECT a.id as archivo_id, a.nombre as name, a.nombre_corto as s_name, a.status, archivo as archivo_path, almacen, anaquel, no_consecutivo, to_char(fecha_creacion, 'mm') mes, to_char(fecha_creacion, 'yyyy') anio, (select codigo from tbl_inv_anaqueles_x_almacen aa where aa.compania = a.company_id and aa.codigo_almacen = a.almacen and aa.cod_anaquel = a.anaquel) anaquel_id, nvl(get_sec_comp_param("+cCompany+",'INV_CONTEO_DISPO'),'I') dispo_where, to_char(fecha_conteo,'dd/mm/yyyy') fechaConteo from tbl_inv_pdt_archivo a where a.id = "+archivoId+" and company_id = "+cCompany;
		cdo = SQLMgr.getData(sql);
		
		archivoId = cdo.getColValue("archivo_id");
		dispoWhere = cdo.getColValue("dispo_where");
		fechaConteo = cdo.getColValue("fechaConteo");
		
		actionText = "Cargar";
		
		alreadyLoaded = CmnMgr.getCount("SELECT count(*) FROM tbl_inv_pdt_archivo_tmp where archivo_id = "+archivoId+" and company_id = "+cCompany);
		
		if (alreadyLoaded > 0 && cdo.getColValue("status") != null ) {
		  if (cdo.getColValue("status").equals("P") || cdo.getColValue("status").equals("C") || cdo.getColValue("status").equals("R")){
			 actionText = "Inactivar";
		  }else {
		    actionText = "Activar";
		  }
		} else if (alreadyLoaded == 0 && cdo.getColValue("status").equals("P")) {
			actionText = "Inactivar";
		}
	}
	
	fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);	
	//
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>

<script type="text/javascript">
function doAction(){
  <%if (alreadyLoaded > 0 ) {%>
    showLoadTmp();
  <%}%>
}
function showLoadTmp(){
  $("#iTmp").attr("src","../inventario/cargar_archivo_pdt_det.jsp?archivoId=<%=archivoId%>");
}

function execAction(action){
   var proceed = false; 
   var msg = "";
	 var nombre = $("#name").val();
   // more validations if needed
   if (action == "Inactivar" ) {$("#status").val("I"); proceed=true;}
   else if (action == "Activar" ) {$("#status").val("A"); proceed=true;}
   else if ( action == "Validar" || action == "Pre Cargar"||action == "Validar" || action == "Cargar" ){
	  if(!$("#anaquel").val() || !$("#almacen").val()){
	    proceed = false;
		alert("Por favor escoger un almacén y un anaquel válidos!");
	  }else if (!$("#fechaConteo").val() && "<%=dispoWhere%>" == "K"){
	    proceed = false;
		alert("Por favor indique la fecha de conteo.");
	  }else proceed = true;
   }
   else if (action == "Imprimir"){
      abrir_ventana("../cellbyteWV/report_container.jsp?reportName=inventario/rpt_archivo_pdt.rptdesign&pArchivoId=<%=archivoId%>&pCtrlHeader=false");
   }else if (action == "Registrar Conteo"){
      showPopWin('../common/run_process.jsp?fp=inventario&actType=1&docType=CONT_FISICO&docId=<%=archivoId%>&docNo='+nombre+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');

   }else if (action == "Registrar Conteo y Actualizar"){
      	showPopWin('../common/run_process.jsp?fp=inventario&actType=2&docType=CONT_FISICO&docId=<%=archivoId%>&docNo='+nombre+'&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');

   }else if (action == "Actualizar"){
      	showPopWin('../common/run_process.jsp?fp=ACTCONTEO&actType=7&docType=ACTCONTEO&docId=<%=cdo.getColValue("no_consecutivo")%>&docNo=<%=cdo.getColValue("no_consecutivo")%>&almacen=<%=cdo.getColValue("almacen")%>&anio=<%=cdo.getColValue("anio")%>&mes=<%=cdo.getColValue("mes")%>&codigo=<%=cdo.getColValue("no_consecutivo")%>&compania=<%=(String) session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.65,null,null,'');

   }else if (action == "Imprimir Diferencia"){
		var company = <%=(String) session.getAttribute("_companyId")%>;
		var consigna = 'N' ;
		var soloDif = 'S';

		abrir_ventana2('../inventario/print_diferencia_sistema.jsp?compania='+company+'&almacen=<%=cdo.getColValue("almacen")%>&anaquelx=<%=cdo.getColValue("anaquel_id")%>&anaquely=&anio=<%=cdo.getColValue("anio")%>&consigna='+consigna+'&consecutivo=<%=cdo.getColValue("no_consecutivo")%>&soloDif='+soloDif);

		}
   
   $("#btnAction").val(action);
   if(proceed==true) $("#form1").submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ARCHIVO PDT"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("id",archivoId)%>
				<%=fb.hidden("dispoWhere",dispoWhere)%>
				<%=fb.hidden("alreadyLoaded",""+alreadyLoaded)%>
				<%=fb.hidden("btnAction","")%>
			<table width="99%" cellpadding="0" cellspacing="1">
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr class="TextRow01" >
				<td>C&oacute;digo</td>
				<td><%=archivoId%></td>
			</tr>
			<tr class="TextRow01" >
				<td width="17%">Almac&eacute;n</td>
				<td width="83%"><%=fb.select(ConMgr.getConnection(),"select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+cCompany+" order by codigo_almacen","almacen",cdo.getColValue("almacen"),false,(mode.equals("edit")),0,null,null,"onchange=loadXML('../xml/anaqueles_x_compania"+UserDet.getUserId()+".xml','anaquel','','VALUE_COL','LABEL_COL','"+cCompany+"@'+this.value,'KEY_COL','')",null,"S")%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Anaquel:&nbsp;<%=fb.select("anaquel",cdo.getColValue("anaquel"),cdo.getColValue("anaquel"),false,false,0,null,"width:130px","",null,"S")%>
		
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<%
				String strStatus = "";
				if(cdo.getColValue("status").equals("") || cdo.getColValue("status").equals("P")) strStatus = "P=Pendiente";
				if(cdo.getColValue("status").equals("C")) strStatus = "C=Cargado";
				if(cdo.getColValue("status").equals("R")) strStatus = "R=Registrado";
				if(cdo.getColValue("status").equals("A")) strStatus = "A=Actualizado";
				strStatus += ", I=Inactivo";
				%>
				Estado:<%=fb.select("status",strStatus,cdo.getColValue("status"),"")%>
				</td>	
			</tr>							
			<tr class="TextRow01" >
				<td>Nombre</td>
				<td><%=fb.textBox("name",cdo.getColValue("name"),true,false,false,55)%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Nombre Corto:<%=fb.textBox("s_name",cdo.getColValue("s_name"),false,false,false,55)%>
				</td>
			</tr>	
			<tr class="TextRow01" >
				<td>Archivo</td>
				<td>
				<%if (mode.equals("add")){%>
				<%=fb.fileBox("archivo","",true,false,15,"","","")%>
				<%}else{%>
				<span><%=cdo.getColValue("archivo_path")%></span>
				<%=fb.hidden("archivo",fileRoot+cdo.getColValue("archivo_path"))%>
				<%}%>
				&nbsp;&nbsp;&nbsp;
				<cellbytelabel id="5">Fecha Conteo</cellbytelabel>
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1"/>
				<jsp:param name="nameOfTBox1" value="fechaConteo"/>
				<jsp:param name="valueOfTBox1" value="<%=fechaConteo%>"/>
				<jsp:param name="readonly" value="<%=!dispoWhere.trim().equalsIgnoreCase("K")?"y":"n"%>"/>
				</jsp:include>
				</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="2" align="right"><!--<font class="RedText">Los articulos en rojo no se registrar&aacute;n en el conteo fisico!.</font>-->

				<%if (cdo.getColValue("status") != null && cdo.getColValue("status").equals("C") && alreadyLoaded > 0){%>
				  <%=fb.button("btnCheck","Validar",true,false,null,null,"onClick=execAction(this.value)")%>
				<%}%>
				<%if (cdo.getColValue("status") != null && cdo.getColValue("status").equals("P")){%>
				  <%=fb.button("btnCargar","Cargar",true,false,null,null,"onClick=execAction(this.value)")%>
				<%}%>
					<%if (cdo.getColValue("status") != null && cdo.getColValue("status").equals("C") && alreadyLoaded > 0){%>
					<authtype type='50'>
				  <%=fb.button("btnCargar","Registrar Conteo",true,false,null,null,"onClick=execAction(this.value)")%>
					</authtype>
					<authtype type='51'>
				  <%=fb.button("btnCargarAct","Registrar Conteo y Actualizar",true,false,null,null,"onClick=execAction(this.value)")%>
					</authtype>
				<%}%>
				<%if (cdo.getColValue("status") != null && cdo.getColValue("status").equals("R") && alreadyLoaded > 0){%>
				<authtype type='52'>
				  <%=fb.button("btnCargarAct","Actualizar",true,false,null,null,"onClick=execAction(this.value)")%>
					</authtype>
				<%}%>
				<%if (cdo.getColValue("status") != null && (cdo.getColValue("status").equals("R") || cdo.getColValue("status").equals("A")) && alreadyLoaded > 0){%>
				<authtype type='52'>
				  <%=fb.button("btnPrintDif","Imprimir Diferencia",true,false,null,null,"onClick=execAction(this.value)")%>
					</authtype>
				<%}%>
				<%if ((cdo.getColValue("status") != null && !cdo.getColValue("status").equals("A") && alreadyLoaded > 0) || mode.equals("add") || (mode.equals("edit") && alreadyLoaded==0 && cdo.getColValue("status")!=null && cdo.getColValue("status").equals("P"))){%>
				<%=fb.button("save",actionText,true,false,null,null,"onClick=execAction(this.value)")%>
				<%}%>
				<%if(cdo.getColValue("status") != null && !cdo.getColValue("status").equals("I")){%>
				<%=fb.button("print","Imprimir",true,false,null,null,"onClick=execAction(this.value)")%>
				<%}%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	

			</table>		
				 <%=fb.formEnd(true)%>
		</td>
	</tr>
	<tr>
		<td>
		<iframe id="iTmp" name="iTmp" src="" style="border:none; width:100%; height:350px"></iframe>
		</td>
	</tr>
</table>
</body>
</html>
<%
}//GET 
else
{
  
  String errorCode = "", errorMsg = "";
  
  alreadyLoaded = Integer.parseInt((String)ht.get("alreadyLoaded"));
  String btnAction = (String)ht.get("btnAction");
System.out.println("btnAction="+btnAction);
  if (!btnAction.equals("Validar")){
	  cdo = new CommonDataObject();
	  cdo.addColValue("archivo",(String)ht.get("archivo"));
	  cdo.addColValue("status",(String)ht.get("status"));
	  if(btnAction.equals("Cargar")) cdo.addColValue("status", "C");
	  cdo.addColValue("company_id",cCompany);
	  cdo.addColValue("usuario_creacion",cUserName);
	  cdo.addColValue("usuario_modificacion",cUserName);
	  cdo.addColValue("qty_filas","0");
	  cdo.addColValue("nombre",(String)ht.get("name"));
	  cdo.addColValue("nombre_corto",(String)ht.get("s_name"));
	  cdo.addColValue("almacen",(String)ht.get("almacen"));
	  cdo.addColValue("anaquel",(String)ht.get("anaquel"));
	  cdo.addColValue("mode",(String)ht.get("mode"));
	  cdo.addColValue("fecha_conteo",(String)ht.get("fechaConteo"));
	  
	  conf.setArchiveHeader(cdo);
	  conf.setAnaquelPos(anaquelPos);
	  conf.setBarCodePos(barCodePos);
	  conf.setQtyPos(qtyPos);
	  conf.setSeparator(separator);
	  
	  cdo.addColValue("id",(String)ht.get("id"));
	  
	  if (alreadyLoaded > 0 || btnAction.equalsIgnoreCase("Inactivar")) cdo.addColValue("mode","inactive");

	  conf.setArchive((String)ht.get("archivo"));
	  ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	  ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"btnAction="+btnAction+"&mode="+mode);
	  PDTA.processFile(conf);
	  ConMgr.clearAppCtx(null);
	  errorCode = PDTA.getErrCode();
	  errorMsg  = PDTA.getErrMsg();
	  
  }else{
    CommonDataObject param = new CommonDataObject();
	param.setSql("call sp_verify_inv_pdt(?,?,?)");
	param.addInStringStmtParam(1,(String)ht.get("id"));
	param.addInStringStmtParam(2,cCompany);
	param.addInStringStmtParam(3,(String) session.getAttribute("_userName"));
	
	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"btnAction="+btnAction+"&mode="+mode);
	param = SQLMgr.executeCallable(param,false,true); 	
	ConMgr.clearAppCtx(null);
	
	errorCode = SQLMgr.getErrCode();
	errorMsg  = SQLMgr.getErrCode().equals("1")?"La validación de los artículos PDT fue exitosa!":SQLMgr.getErrCode();
  }
  
%>
<html>
<head>
<script type="text/javascript">
function closeWindow()
{
<%
if (errorCode.equals("1"))
{
%>
	alert('<%=errorMsg%>');
	window.location = '<%=request.getContextPath()%>/inventario/cargar_archivo_pdt_config.jsp?mode=edit&archivoId=<%=(String)ht.get("id")%>';
<%
} else throw new Exception(errorMsg);
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