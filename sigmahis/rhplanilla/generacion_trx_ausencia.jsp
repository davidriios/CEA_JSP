<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<%
///---------
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList uni = new ArrayList();
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fg = request.getParameter("fg");
String fp = request.getParameter("fp");
String quincena = request.getParameter("quincena");
String area = request.getParameter("area");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String unidad = request.getParameter("unidad");

fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);
if(fg==null) fg = "";
if(quincena==null) quincena = "";
if(area==null) area = "";
if(fp==null) fp = "";
if(anio==null) anio = "";
if(mes==null) mes = "";
if(unidad==null) unidad = "";

boolean viewMode = false;

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String dia = CmnMgr.getCurrentDate("dd");
if(anio.equals("") && mes.equals("")){
	anio = cDateTime.substring(6, 10);
	mes = cDateTime.substring(3, 5);
}
String mTime = CmnMgr.getCurrentDate("hh12:mi:ss am");
String fecha = request.getParameter("fecha");
String periodo = request.getParameter("periodo");
int day = Integer.parseInt(CmnMgr.getCurrentDate("dd"));
int mont = Integer.parseInt(CmnMgr.getCurrentDate("mm"));
int period=0;
if(fecha==null) fecha = cDateTime;
int lineNo = 0;
if (mode == null) mode = "add";

if (day<=15) {
	period		= (mont * 2)-1;
	quincena	= "PRIMERA";
}	else {
	period		= (mont * 2);
	quincena	= "SEGUNDA";
}
periodo= ""+period;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	cdo.addColValue("fechaHoy",CmnMgr.getCurrentDate("dd/mm/yyyy"));
	sql="select periodo, to_char(trans_desde,'dd/mm/yyyy') as trans_desde, to_char(trans_hasta,'dd/mm/yyyy') as trans_hasta, to_char(fecha_cierre,'dd/mm/yyyy') as fechaCierre, to_char(fecha_final,'dd/mm/yyyy') as fechaFinal, to_char(fecha_inicial,'dd/mm/yyyy') as fechaInicial, to_char(fecha_inicial,'FMMONTH','NLS_DATE_LANGUAGE = SPANISH') as mes from tbl_pla_calendario where periodo = "+periodo+" and to_char(fecha_cierre,'dd/mm/yyyy') < '"+fecha+"' and to_char(fecha_inicial,'dd/mm/yyyy') <= '"+fecha+"' and to_char(fecha_final,'dd/mm/yyyy') >= '"+fecha+"' and tipopla=1";
	cdo = SQLMgr.getData(sql);
	al=SQLMgr.getDataList(sql);

	uni = sbb.getBeanList(ConMgr.getConnection(), "select codigo as optValueColumn, descripcion as optLabelColumn from tbl_pla_ct_grupo where compania="+(String) session.getAttribute("_companyId")+" order by descripcion", CommonDataObject.class);

	System.out.println("sql = "+al.size()+"//"+sql);

		if(al.size()<=0)
	  {
			fecha=" ";
			quincena=" ";
			mes=" ";
			anio=" ";
		  periodo= "";
		}

%>
<html>
<head>
<script type="text/javascript">
function verocultar(c) { if(c.style.display == 'none'){       c.style.display = 'inline';    }else{       c.style.display = 'none';    }    return false; }
</script>
<%@ include file="../common/tab.jsp" %>
<script language="JavaScript">function bcolor(bcol,d_name){if (document.all){ var thestyle= eval ('document.all.'+d_name+'.style'); thestyle.backgroundColor=bcol; }}</script>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'PLANILLA - '+document.title;
</script>
<script language="javascript">
function doSubmit(value){
	window.frames['itemFrame'].document.form.baction.value = value;
	window.frames['itemFrame'].doSubmit(value);
}

function printEnvios()
{
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	var quincena = document.form1.quincena.value;

	abrir_ventana('../rhplanilla/print_envio_solicitud_vac.jsp?quincena='+quincena+'&anio='+anio+'&mes='+mes);
}


function doAction(){
var size = window.frames['itemFrame'].document.form.keySize.value;
	document.form1.count.value = size;
	setHeight('itemFrame',document.body.scrollHeight);

}

function setValues(){
	var mes = document.form1.mes.value;
	var anio = document.form1.anio.value;
	var quincena = document.form1.quincena.value;

	var periodo = document.form1.periodo.value;
	if(periodo!='' ){
	var cierre  = document.form1.fechaCierre.value;
	var inicio  = document.form1.fechaInicial.value;
	var final   = document.form1.fechaFinal.value;
	var unidad  = document.form1.unidad.value;
	var desde   = document.form1.fechaTrxDesde.value;
	var hasta   = document.form1.fechaTrxHasta.value;


		window.frames['itemFrame'].location = '../rhplanilla/genera_trx_ausencia_det.jsp?anio='+anio+'&desde='+desde+'&hasta='+hasta+'&periodo='+periodo+'&inicio='+inicio+'&final='+final+'&unidad='+unidad+'&fp=<%=fp%>';

		var size = window.frames['itemFrame'].document.form.keySize.value;
	document.form1.count.value = size;
	}
}

function selAll(){
	var size = window.frames['itemFrame'].document.form.keySize.value;
	for(i=0;i<size;i++){
		eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked = true;
		document.form1.count.value = size;
	  document.form1.count1.value = i+1;
		}

}
function deselAll(){
	var size = window.frames['itemFrame'].document.form.keySize.value;
	for(i=0;i<size;i++){
		eval('window.frames[\'itemFrame\'].document.form.chk'+i).checked = false;
		document.form1.count.value = size;
		document.form1.count1.value = 0;
	}
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="GENERACION DE TRANSACCIONES DE AUSENCIA Y TARDANZAS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td class="TableBorder"><table align="center" width="100%" cellpadding="5" cellspacing="0">
              <tr>
                <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
                    <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                    <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
										<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
                    <%=fb.formStart(true)%>
										<%=fb.hidden("mode",mode)%>
										<%=fb.hidden("errCode","")%>
										<%=fb.hidden("errMsg","")%>
										<%=fb.hidden("baction","")%>
										<%=fb.hidden("fg",fg)%>
										<%=fb.hidden("fp",fp)%>
										<%=fb.hidden("clearHT","")%>

										<% if(al.size()>0) {
										%>
										<%=fb.hidden("fechaInicial",cdo.getColValue("fechaInicial"))%>
										<%=fb.hidden("fechaFinal",cdo.getColValue("fechaFinal"))%>
										<%=fb.hidden("fechaTrxDesde",cdo.getColValue("trans_desde"))%>
										<%=fb.hidden("fechaTrxHasta",cdo.getColValue("trans_hasta"))%>
										<%=fb.hidden("fechaCierre",cdo.getColValue("fechaCierre"))%>
										<%=fb.hidden("mes",cdo.getColValue("mes"))%>
										<%=fb.hidden("periodoTrx",cdo.getColValue("periodo"))%>
										<%=fb.hidden("unidadOrgani",unidad)%>
										<% } %>


									<% int i= 0; %>
           <tr>
             <td><table width="100%" cellpadding="1" cellspacing="0">
                <tr class="TextPanel">
                   <td colspan="2">&nbsp;</td>
                </tr>

							  <tr class="TextHeader">
                   <td colspan="2">&nbsp;PARAMETROS PARA GENERACION DE TRANSACCIONES</td>
                </tr>

								<tr class="TextRow01">
									 <td>&nbsp; No. de Periodo :&nbsp;<%=fb.textBox("periodo",periodo,true,false,true,4,"text10","","")%>&nbsp; &nbsp; A&ntilde;o : &nbsp;	<%=fb.textBox("anio",anio,true,false,true,4,"text10","","")%> &nbsp; &nbsp;Mes : &nbsp;
<%=fb.textBox("mes",mes,true,false,true,15,"text10","","")%>&nbsp; &nbsp;
Quincena : &nbsp; <%=fb.textBox("quincena",quincena,true,false,true,10,"text10","","")%>&nbsp; &nbsp;
Fecha de Cierre : &nbsp;<%=fb.textBox("fecha",fecha,true,false,true,15,"text10","","")%>

                            </td>
                            <td>&nbsp;</td>
                          </tr>
													 <tr class="TextHeader">
                            <td colspan="2">&nbsp;</td>
                          </tr>
													 <tr class="TextRow02">
                            <td colspan="2">&nbsp; Unidad a Generar :  <%=fb.select("unidad",uni,unidad,"T")%> <%=fb.button("ir","Ir",false,false,"text10","","onClick=\"javascript:setValues();\"")%></td>
                          </tr>
                        </table></td>
                    </tr>
                    <tr>
                      <td><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="100" scrolling="yes" src="../rhplanilla/genera_trx_ausencia_det.jsp?fp=<%=fp%>&fg=<%=fg%>&mode=<%=mode%>&anio=<%=anio%>&mes=<%=mes%>&unidad=<%=unidad%>&periodo=<%=periodo%>"></iframe></td>
                    </tr>
                    <tr class="TextRow02">
                      <td align="right">
											Total de Empleados : <%=fb.textBox("count","",false,false,true,4,"text10","","")%> &nbsp;&nbsp;&nbsp;
											Total Seleccionados : <%=fb.textBox("count1","",false,false,true,4,"text10","","")%> &nbsp;&nbsp;&nbsp;
											<%=fb.button("generar","GENERAR TRANSACCIONES PARA CALCULO DE PLANILLA",true,false,"","","onClick=\"javascript:doSubmit(this.value);\"")%>

                      <%=fb.button("sel_all","Selecc. Todos",true,false,"","","onClick=\"javascript:selAll();\"")%>
                      <%=fb.button("desel_all","Desel. Todos",true,false,"","","onClick=\"javascript:deselAll();\"")%>
                      </td>
                    </tr>
                    <%=fb.formEnd(true)%>

                    <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                  </table></td>
              </tr>
            </table></td>
        </tr>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
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
	String errCode = "";
	String errMsg = "";
	fp = request.getParameter("fp");
	if (request.getParameter("baction").equalsIgnoreCase("Guardar"))
	{
		errCode = request.getParameter("errCode");
		errMsg = request.getParameter("errMsg");
	}

%>
<html>
<head>
<script language="javascript" src="../web/js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&quincena=<%=quincena%>&anio=<%=request.getParameter("anio")%>&mes=<%=request.getParameter("mes")%>';
<%
} else throw new Exception(errMsg);
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
