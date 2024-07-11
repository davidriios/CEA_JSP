<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();

ArrayList al = new ArrayList();
ArrayList alWh = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
String almacen = request.getParameter("almacen");
String compania = request.getParameter("compania"); 
String wh = request.getParameter("wh");
String fg = request.getParameter("fg");
String familyCode = "";
String classCode = "";


boolean viewMode = false;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (compania == null) compania = (String) session.getAttribute("_companyId");	
alWh = sbb.getBeanList(ConMgr.getConnection(), "select codigo_almacen as optValueColumn, codigo_almacen||' - '||descripcion as optLabelColumn from tbl_inv_almacen where compania="+(String) session.getAttribute("_companyId")+" order by codigo_almacen", CommonDataObject.class);
if (wh == null || wh.trim().equals(""))
{
  if (alWh.size() > 0)
	{ 
		wh = ((CommonDataObject) alWh.get(0)).getOptValueColumn();
	}
  else wh = "";
}

XMLCreator xml = new XMLCreator(ConMgr);
xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+java.io.File.separator+"anaqueles_x_compania"+UserDet.getUserId()+".xml","select * from (select codigo as value_col, codigo||' - '||descripcion as label_col, compania||'@'||codigo_almacen as key_col  from tbl_inv_anaqueles_x_almacen ana where compania = "+(session.getAttribute("_companyId"))+" and cod_anaquel is not null ) z order by 2 asc");

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Reportes -  Inventario Punto de Reorden- '+document.title;
function doAction()
{
}
function showArea()
{
		
}
function showReporte(value, bi)
{
	  var consignacion = eval('document.form0.consignacion').value;
    var almacen = eval('document.form0.almacen').value;
	  var compania = eval('document.form0.compania').value;
	  var banco_med = eval('document.form0.banco_med').value;
    var comparacion = $("#comparacion");
    var $anaquel = $("#anaquel");
    var comparacionText = comparacion.selText();
    var anaquelText = $anaquel.selText();
    var anaquel = $anaquel.val();
    var comparacionLimite = document.getElementById("comparacion_limite").value;
    var excluirZero = document.getElementById("excluir_zero").checked;
    var fDocDesde = $("#f_doc_desde").val();
    var fDocHasta = $("#f_doc_hasta").val();
    
    if (value == 1) {
      if (!bi) abrir_ventana2('../inventario/print_list_punto_reorden_art.jsp?consignacion='+consignacion+'&almacen='+almacen+'&banco='+banco_med+'&comparacion='+comparacion.val()+'&comparacion_limite='+comparacionLimite+'&excluir_zero='+excluirZero+'&comparacion_text='+comparacionText+'&f_doc_desde='+fDocDesde+'&f_doc_hasta='+fDocHasta);
      else {
        consignacion = consignacion || 'N';
        almacen = almacen || 'ALL';
        banco_med = banco_med || 'ALL';
        comparacion = comparacion.val() || 'ALL';
        comparacionLimite = comparacionLimite || 'ALL';
        excluirZero = excluirZero || 'ALL';
        comparacionText = comparacionText || 'ALL';
        fDocDesde = fDocDesde || 'ALL';
        fDocHasta = fDocHasta || 'ALL';
        anaquel = anaquel || 'ALL';
        
        abrir_ventana2('../cellbyteWV/report_container.jsp?reportName=inventario/print_list_punto_reorden_art.rptdesign&pCtrlHeader=true&consignacion='+consignacion+'&almacen='+almacen+'&banco='+banco_med+'&comparacion='+comparacion+'&comparacion_limite='+comparacionLimite+'&excluir_zero='+excluirZero+'&comparacion_text='+comparacionText+'&f_doc_desde='+fDocDesde+'&f_doc_hasta='+fDocHasta+'&anaquel='+anaquel+'&anaquel_text='+anaquelText);
      }
    }
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

	<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REPORTE DE INVENTARIO PUNTO DE REORDEN."></jsp:param>
	</jsp:include>


<table align="center" width="75%" cellpadding="0" cellspacing="0">   
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>  
<td class="TableLeftBorder TableTopBorder TableBottomBorder TableRightBorder">		
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> 
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("baction","")%>
			
		<tr class="TextFilter">
			<td width="15%">Compañia</td>
		
			<td width="35%">
			<%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,nombre||' - '||codigo FROM   tbl_sec_compania where codigo = "+(String) session.getAttribute("_companyId")+" ORDER BY 1","compania",(String) session.getAttribute("_companyId"),false,false,0,null,null,"onChange=\"javascript:loadXML('../xml/almacenes.xml','almacen','"+almacen+"','VALUE_COL','LABEL_COL',this.value,'KEY_COL','S')\"")%>
			</td>
		
			<td width="50%">											
			Almacen
			<%=fb.select("almacen","","",false, false, 0,null,"width:130px","onchange=loadXML('../xml/anaqueles_x_compania"+UserDet.getUserId()+".xml','anaquel','','VALUE_COL','LABEL_COL','"+(session.getAttribute("_companyId"))+"@'+this.value,'KEY_COL','S')",null,"S")%>					
      <script language="javascript">
			loadXML('../xml/almacenes.xml','almacen','<%=almacen%>','VALUE_COL','LABEL_COL','<%=(compania != null && !compania.equals(""))?compania:"document.form0.compania.value"%>','KEY_COL','S');
			</script>
			
			</td>
		</tr>
		
		<tr class="TextFilter">
			<td>Anaquel</td>
			<td colspan="2">
				<%=fb.select("anaquel","","",false,false,0,null,"width:130px","",null,"S")%>
				<script>
          loadXML('../xml/anaqueles_x_compania<%=UserDet.getUserId()%>.xml','anaquel','<%=""%>','VALUE_COL','LABEL_COL','<%=(String) session.getAttribute("_companyId")%>@<%=""%>','KEY_COL','S');
				</script>
		 	</td>
		</tr>
		
		<tr class="TextFilter">
			<td>Consignaci&oacute;n</td>
			<td colspan="2">
				<%=fb.select("consignacion","S=SI,N=NO","N","S")%>					
		 	</td>
		</tr>
		<tr class="TextFilter">
			<td>Banco de Medicamento</td>
			<td colspan="2"><%=fb.select("banco_med","S=SI,N=NO","N","S")%></td>
		</tr>
        <tr class="TextFilter">
			<td>Comparaci&oacute;n</td>
			<td colspan="2"><%=fb.select("comparacion","1=Punto Reorden IGUAL al Disponible,2=Punto Reorden < Disponible,3=Punto Reorden > Disponible","","T")%>&nbsp;&nbsp;&nbsp;
            <%=fb.textBox("comparacion_limite","",false,false,false,10,10)%>&nbsp;&nbsp;&nbsp;
            <label>
            <input type="checkbox" id="excluir_zero" name="excluir_zero">Excluir sin punto de reorden<label>
            </td>
		</tr>
		
		
		<tr class="TextFilter">
			<td>Fecha documento</td>
			<td colspan="2">
			<jsp:include page="../common/calendar.jsp" flush="true">
		<jsp:param name="fieldClass" value="Text10"/>
		<jsp:param name="noOfDateTBox" value="2"/>
		<jsp:param name="clearOption" value="true"/>
		<jsp:param name="nameOfTBox1" value="f_doc_desde"/>
		<jsp:param name="valueOfTBox1" value="<%=cDateTime.substring(0,11)%>"/>
		<jsp:param name="nameOfTBox2" value="f_doc_hasta"/>
		<jsp:param name="valueOfTBox2" value="<%=cDateTime.substring(0,11)%>"/>
		</jsp:include>
		</td>
		</tr>
		
		<tr class="TextHeader">
			<td colspan="3">Reportes</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3">
			<!-- showReporte(this.value) -->
        <%=fb.radio("reporte1","1",true,false,false,null,null,"")%>Punto de Reorden
        &nbsp;&nbsp;&nbsp;&nbsp; 
        <a href="javascript:showReporte(1, 'BI')">Excel</a>
			</td>
		</tr>
	
		
		
		</table>
</td></tr>
		
		<tr><td>&nbsp;</td></tr>

			
	<%fb.appendJsValidation("if(error>0)doAction();");%>		

<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

</table>
</body>
</html>
<%
}//GET
%>
