<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String mode = request.getParameter("mode");
String highlightClass = "TextRow03 Text12Bold";
String estado = request.getParameter("estado");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String docId = request.getParameter("docId")==null?"":request.getParameter("docId");
String fg = request.getParameter("fg")==null?"":request.getParameter("fg");
String desc = request.getParameter("desc")==null?"":request.getParameter("desc");
String seccion = request.getParameter("seccion")==null?"":request.getParameter("seccion");
String defaultAction = request.getParameter("defaultAction")==null?"":request.getParameter("defaultAction");
String _viewMode = request.getParameter("_viewMode")==null?"":request.getParameter("_viewMode");
String boletaAdm = request.getParameter("boletaAdm")==null?"":request.getParameter("boletaAdm");

if (mode == null) mode = "add";
if (estado == null) estado = "";

if (docId.trim().equals("")) throw new Exception("El número del documento es inválido. Contacte su administrador!");
if (seccion.trim().equals("")) throw new Exception("La sección del documento es inválida. Contacte su administrador!");

if (fg.trim().equalsIgnoreCase("DOC_MED")){
  sql = "select a.codigo, a.descripcion, a.report_order, a.report_path from tbl_sal_expediente_secciones a where a.report_path is not null order by a.descripcion";
}else
sql = "select a.codigo, a.descripcion, b.display_order, a.report_path from tbl_sal_expediente_secciones a, tbl_sal_exp_docs_secc b where b.doc_id="+docId+"  and a.codigo=b.secc_code and a.status = 'A' and a.report_path is not null order by a.descripcion";

al = SQLMgr.getDataList(sql);

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<!doctype html>
<html>
<head><!--1876px 1756px-->
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<style type="text/css">
#loading{position:absolute;z-index:200;text-align:center;font-family:"Trebuchet MS", verdana, arial,tahoma;font-size:18pt;background: rgba(0,0,0,0.6);width: 100%;color:#fff;text-align:center;}
#content{position: fixed;z-index:201;display: block;left: 50%;margin-top: 120px;width: 500px;text-align:center;margin-left:-250px;}
</style>
<script>
document.title="Expediente - "+document.title;
function getTdHeight(){
   return Math.max(document.getElementById("container")["clientHeight"], document.getElementById("container")["scrollHeight"],document.documentElement["offsetHeight"]);
}

function doAction(){
    newHeight();
	<%if(request.getParameter("showPrinting")!=null){%>
      var size = document.getElementById("size").value;	
	  abrir_ventana("../expediente/print_unified_exp.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&cds=<%=cds%>&boletaAdm=<%=boletaAdm%>&size="+size);
	<%}%>
}

function _checkAll(){
 var size = document.getElementById("size").value;
   if ( document.getElementById("check").checked == true ){
	   document.getElementById("printU").disabled = "";
	   document.getElementById("printB").disabled = "";
       for (i = 0; i<size; i++){
          document.getElementById("option"+i).checked = "checked";
		  document.getElementById("orden"+i).value = (i+1);
		  document.form0.ultimoOrden.value = (i+1);
        }//for i 
   }//if checked
   else{
       for (i = 0; i<size; i++){
	      document.getElementById("printU").disabled = "disabled";
	      document.getElementById("printB").disabled = "disabled";
          document.getElementById("option"+i).checked = "";
		  document.getElementById("orden"+i).value = "";
		   
       }//for i 
	   document.form0.ultimoOrden.value = 0;
  }
}
function checkOrden(id,fg){
var size = document.form0.size.value;
var ultimoOrden = parseInt(document.form0.ultimoOrden.value);
var orden =0;
var x=0;
if(eval('document.form0.option'+id).checked==true || (fg=='OM' && eval('document.form0.orden'+id).value !='' ))
{
	x++;
	if(fg =='AU')
	{
		if(ultimoOrden ==0)orden=1;else orden = ultimoOrden+1;
		document.form0.ultimoOrden.value = orden;
		eval('document.form0.orden'+id).value = orden;
	}
	else
	{
		if(eval('document.form0.option'+id).checked !=true && eval('document.form0.orden'+id).value !='')
	    eval('document.form0.option'+id).checked  = true;
		
		  var ordenDesel = eval('document.form0.orden'+id).value;
		  var ordenDeselX = 0;
		  if(ultimoOrden ==0){  document.form0.ultimoOrden.value = ordenDesel;ultimoOrden=ordenDesel;}
		  else if(ultimoOrden < ordenDesel) ultimoOrden = ordenDesel;
		  
		  for (var i=0; i <size; i++)
		  {
			  if(eval('document.form0.orden'+i).value !='' &&( i != id && ordenDesel !='' ))
			  {
				if(parseInt(eval('document.form0.orden'+i).value) ==  ordenDesel)
				{
					alert('El valor ya existe');
					eval('document.form0.orden'+id).value='';
					 eval('document.form0.option'+id).checked  = false;
				}
				else{  if(parseInt(eval('document.form0.orden'+i).value) >  ordenDesel && parseInt(eval('document.form0.orden'+i).value) > ultimoOrden )ultimoOrden = eval('document.form0.orden'+i).value;}
				
				if(ultimoOrden < parseInt(eval('document.form0.orden'+i).value))
				ultimoOrden =  parseInt(eval('document.form0.orden'+i).value);
			  }else
			  {
			    if(eval('document.form0.option'+id).checked==true && eval('document.form0.orden'+i).value=='')eval('document.form0.option'+i).checked  = false;
			  }			  			  		  
		  }
		  document.form0.ultimoOrden.value = ultimoOrden;
	}
}
else
{
  var ordenDesel = eval('document.form0.orden'+id).value;
  var ordenDeselX = 0;
  eval('document.form0.orden'+id).value ='';

  for (var i=0; i <size; i++)
  {
  	  if(eval('document.form0.orden'+i).value !='')
	  {
	  	if(parseInt(eval('document.form0.orden'+i).value) >  ordenDesel)
		{
			ordenDeselX = eval('document.form0.orden'+i).value;
			eval('document.form0.orden'+i).value=ordenDesel;
			if(ordenDesel !=0)orden = ordenDesel;
			else  orden = ordenDeselX ;
			ordenDesel = ordenDeselX;
		}
		else orden = eval('document.form0.orden'+i).value;
	  }
  }
  document.form0.ultimoOrden.value = orden;
}
goPrint();
}
function checkBoleta(){
    if ( document.getElementById("boletaAdm").checked == true ){
		document.getElementById("printU").disabled = "";
		document.getElementById("printB").disabled = "";
	}else{goPrint();}
}
function goPrint(){
     var size = document.getElementById("size").value;
     var counter = 0;
	 if ( document.getElementById("boletaAdm").checked != true ){ 
		 for ( i = 0; i<size; i++ ){
			  if ( document.getElementById("option"+i).checked == true ){
				 counter++;
			  }
		 }
		 if ( counter < 1){
			 document.getElementById("printU").disabled = "disabled";  
			 document.getElementById("printB").disabled = "disabled";  
			 return false;
		 }else{
			document.getElementById("printU").disabled = "";
			document.getElementById("printB").disabled = "";
			return true;
		 }
	 }else{
	   return true;
	 }
 }
 
 $(document).ready(function(){
  $("#printU,#printB").click(function(c){
    var tdH = getTdHeight() < 390 ? getTdHeight()+390: getTdHeight();
    $("#loading").height(tdH).show(0);
	setTimeout(function(){$("#form0").submit();},500);
  });
  
  filterHTML({tblId:"tbl_content", txtId:"search", ignoreRows:{h:2,f:1}, blockCheckAllId:"check" });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="LISTADO DE REPORTES"></jsp:param>
	<jsp:param name="displayCompany" value="y"></jsp:param>
	<jsp:param name="displayLineEffect" value="y"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
    <tr>
		<td class="TableBorder">
		    <table width="100%" border="0" cellpadding="0" cellspacing="0">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("section","")%>
				<%=fb.hidden("highlightClass",highlightClass)%>
				<%=fb.hidden("size",""+al.size())%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("cds",cds)%>
				<%=fb.hidden("docId",docId)%>
				<%=fb.hidden("estado",estado)%>
				<%=fb.hidden("fg",fg)%>
				<%=fb.hidden("desc",desc)%>
				<%=fb.hidden("defaultAction",defaultAction)%>
				<%=fb.hidden("_viewMode",_viewMode)%>
				<%=fb.hidden("seccion",seccion)%>
				<%=fb.hidden("ultimoOrden","0")%>
				<%fb.appendJsValidation("if(!goPrint()){CBMSG.error('No podemos procesar su orden, al menos selecciona un reporte.',{cb:function(r){ if (r=='Ok') $('#loading').hide(0);}});error++;}");%>
				<tr class="TextRow02" align="right">
					<td><input type="text" id="search" placeholder="Buscar" autocomplete="off" />&nbsp;&nbsp;&nbsp;</td>
				</tr>
                <tr>
					<td id="container" colspan="3">
						<table width="100%" border="0" cellpadding="1" cellspacing="1" id="tbl_content">
							<tr>
								<td colspan="3"> 
									<div id="loading" style="display:none;">
										<div id="content">&nbsp;Preparando el PDF....<br><img src="<%=request.getContextPath()%>/images/loading-bar2.gif"></div>
									</div>
								</td>
							</tr>
							
							<tr class="TextHeader" align="center">
								<td align="right" width="85%">
								  <cellbytelabel id="1">INCLUIR BOLETA DE ADMISION</cellbytelabel></td>
								<td width="5%"><%=fb.checkbox("boletaAdm","S",false,false,null,null,"onClick=\"checkBoleta()\"","Incluir boleta de admisión!")%></td>
								<td width="10%"><%=fb.button("printU","Imprimir",true,true,null,null,"")%></td>
							</tr>
							<tr class="TextHeader" align="center">
								<td align="left">&nbsp;<cellbytelabel id="2">Secciones</cellbytelabel></td>
								<td><%=fb.checkbox("check","",false,false,null,null,"onkeypress =\"_checkAll()\" onClick=\"_checkAll()\"","Seleccionar todas las secciones listadas!")%></td>
								<td><cellbytelabel id="4">Orden</cellbytelabel></td>
							</tr>
							<%
							for (int i=0; i<al.size(); i++)
							{
								cdo = (CommonDataObject) al.get(i);
								String color = "TextRow02";
								

								if ( i%2 == 0 ) color = "TextRow01";
							%>
									<%=fb.hidden("report_path"+i, cdo.getColValue("report_path"))%>
									<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
									<%=fb.hidden("ordenVal"+i,""+i)%>
									<%//=fb.hidden("path"+i,cdo.getColValue("path"))%>
									<%=fb.hidden("desc"+i,""+cdo.getColValue("descripcion"))%>
									<%=fb.hidden("seccion"+i,""+cdo.getColValue("codigo"))%>
									<tr class="<%=color%>" onMouseOver="setoverc(this,(document.form0.section.value==<%=cdo.getColValue("codigo")%>)?'TextRowOver Text12Bold':'TextRowOver')" onMouseOut="setoutc(this,(document.form0.section.value==<%=cdo.getColValue("codigo")%>)?'<%=highlightClass%>':'<%=color%>')" id="section<%=cdo.getColValue("codigo")%>" align="center">
										<td align="left">&nbsp;<%=cdo.getColValue("descripcion")+" ["+cdo.getColValue("codigo")+"]"%></td>
										<td><%=fb.checkbox("option"+i, cdo.getColValue("codigo"), false, false, null, null, "onClick=\"javascript:checkOrden("+i+",'AU')\"")%></td>
										<td><%=fb.intBox("orden"+i,"", false, false, false, 2, (String.valueOf(al.size()).trim().length()), null, null, "onBlur=\"checkOrden("+i+",'OM')\"")%></td>
									</tr>
							<%
							}
							%>
							<tr class="TextHeader" align="center">
								<td colspan="2"></td>
								<td><%=fb.button("printB","Imprimir",true,true,null,null,"")%></td>
							</tr>
						</table>	
						<%=fb.formEnd(true)%>
	    </td>
    </tr>
</table>
</body>
</html>
<%
}//GET
else{ 
  
  System.out.println("::::::::::::::::::::::::::::: POSTING....");
  
  int size = Integer.parseInt(request.getParameter("size"));
  
  Object alRpt[]=new Object[size]; 
  int indexal=-1;
	
  for (int i=0; i<size; i++){
  
    if ( request.getParameter("option"+i) != null && !request.getParameter("option"+i).equals("")){
	
		cdo = new CommonDataObject();
		indexal=-1;
		
		cdo.addColValue("codigo",request.getParameter("codigo"+i));
		cdo.addColValue("desc",request.getParameter("desc"+i));
		cdo.addColValue("orden",request.getParameter("orden"+i));
		cdo.addColValue("page",request.getParameter("report_path"+i));
		cdo.addColValue("seccion",request.getParameter("seccion"+i));
		
		try{
		   indexal = Integer.parseInt(request.getParameter("orden"+i));
		}catch(Exception nfe){ 
		   System.err.println(nfe.getMessage());
		}
		if(indexal!=-1) {
		  alRpt[--indexal]=cdo;
		}
		
	} // if option
  } // for i
 
   session.setAttribute("_alRpt",alRpt);
%>

<!doctype html>
<html>
<head>
<script>
function closeWindow()
{
   <%if ( (alRpt != null && alRpt.length > 0) || request.getParameter("boletaAdm")!=null ){%>
     document.location.href = "<%=request.getContextPath()%>/expediente/expediente_gral.jsp?fg=<%=request.getParameter("fg")%>&desc=<%=request.getParameter("desc")%>&pacId=<%=request.getParameter("pacId")%>&noAdmision=<%=request.getParameter("noAdmision")%>&seccion=<%=request.getParameter("seccion")%>&defaultAction=<%=request.getParameter("defaultAction")%>&docId=<%=request.getParameter("docId")%>&cds=<%=request.getParameter("cds")%>&_viewMode=<%=request.getParameter("_viewMode")%>&showPrinting=1<%=(request.getParameter("boletaAdm")!=null?"&boletaAdm=S":"")%>&size=<%=request.getParameter("size")%>"; 
   <%}%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
} // POST
%>