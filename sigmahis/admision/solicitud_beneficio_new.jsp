<%//@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admin.XMLCreator"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
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
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String empresa = request.getParameter("empresa");
String nombreEmpresa = request.getParameter("nombreEmpresa");
String categoria = request.getParameter("categoria");
String categoriaDesc = request.getParameter("categoriaDesc");
String secuencia = request.getParameter("secuencia");
String tipoPoliza = request.getParameter("tipo_poliza");
String tipoPlan = request.getParameter("tipo_plan");
String certificado = request.getParameter("certificado");
String poliza = request.getParameter("poliza");
String change = request.getParameter("change");
String pacId = request.getParameter("pac_id");
String noAdmision = request.getParameter("admision");
String compania = (String) session.getAttribute("_companyId");
String cUserName = (String) session.getAttribute("_userName");

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (nombreEmpresa == null) nombreEmpresa = "";

if (tab == null) tab = "0";
if (mode == null) mode = "add";

CommonDataObject cdo = new CommonDataObject();
int totSol = 0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	
    XMLCreator xml = new XMLCreator(ConMgr);
    xml.create(java.util.ResourceBundle.getBundle("path").getString("xml")+java.io.File.separator+"tipo_plan_x_poliza"+UserDet.getUserId()+".xml","select tipo_plan value_col, nombre label_col, poliza key_col from tbl_adm_tipo_plan  where not nombre like 'NO USAR%' order by 1,2");
    
    totSol  = CmnMgr.getCount("select count(*)as cantidad from tbl_ase_convenio a ,tbl_adm_beneficios_x_admision b where a.pac_id = "+pacId+" and a.admision="+noAdmision+" and a.empresa=b.empresa and a.pac_id=b.pac_id and b.prioridad=1 and a.estado='A'");
    
    if (totSol > 1) throw new Exception("Encontramos mas de una solicitud para esa admisión. Por favor contacte a su administrador!");
    
    if (totSol == 1){
       mode = "edit";
       sql = "select c.id, to_char(c.fecha,'dd/mm/yyyy') fecha, c.estado, c.tipo tipo_beneficio, c.empresa, e.nombre nombreEmpresa, c.tipo_plan, c.tipo_poliza, c.categoria, cat.descripcion categoriaDesc, c.monto_cli, c.monto_pac, c.monto_emp, c.tipo_val_cli, c.tipo_val_pac, c.tipo_val_emp, c.tipo_cob_cli, c.tipo_cob_emp, c.tipo_pago_pac, c.tipo_pago_emp, c.poliza, c.certificado, c.observacion from tbl_ase_convenio c, tbl_adm_empresa e, tbl_adm_categoria_admision cat where c.compania = "+compania+" and c.pac_id = "+pacId+" and admision = "+noAdmision+" and e.codigo = c.empresa and cat.codigo = c.categoria and rownum = 1";
		
       cdo = SQLMgr.getData(sql);
       
       secuencia = cdo.getColValue("id","");
    }
    
    if (mode.equalsIgnoreCase("add"))
	{
		cdo = SQLMgr.getData("select y.codigo empresa, y.nombre nombreEmpresa, z.poliza, z.tipo_poliza, z.tipo_plan, z.certificado from (select * from tbl_adm_beneficios_x_admision where pac_id="+pacId+" and admision="+noAdmision+" and prioridad=1 and nvl(estado,'A')='A') z, tbl_adm_empresa y where z.empresa=y.codigo");
        
        secuencia = "0";
        cdo.addColValue("secuencia", secuencia);
        cdo.addColValue("fecha", cDateTime.substring(0,10));
        cdo.addColValue("categoria", categoria);
        cdo.addColValue("categoriaDesc", categoriaDesc);
	}
    
    boolean viewMode = mode.equalsIgnoreCase("view");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script>
document.title = 'Solicitud de Beneficio - '+document.title;

function doAction(){}

$(document).ready(function(){
    $("#save").click(function(){
      $("#form0").submit()
    });
    
    
    //Lazy loading iframes
    lazyLoadingIF();
})

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE SOLICITUD DE BENEFICIO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

                <!-- MAIN DIV START HERE -->
                <div id="dhtmlgoodies_tabView1">


                <!-- TAB0 DIV START HERE-->
                <div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">
                
                <tr class="TextRow02">
					<td>
                    <jsp:include page="../common/paciente.jsp" flush="true">
                        <jsp:param name="pacienteId" value="<%=pacId%>"></jsp:param>
                        <jsp:param name="mode" value="view"></jsp:param>
                        <jsp:param name="admisionNo" value="<%=noAdmision%>"></jsp:param>
                    </jsp:include>
                    </td>
				</tr>
                
                <tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

                <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                <%=fb.formStart(false)%>
                <%=fb.hidden("tab","0")%>
                <%=fb.hidden("mode",mode)%>
                <%=fb.hidden("baction","")%>
                <%=fb.hidden("secuencia",secuencia)%>
                <%=fb.hidden("pac_id",pacId)%>
                <%=fb.hidden("admision",noAdmision)%>

				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
                        
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Empresa</cellbytelabel></td>
							<td>
								<%=fb.intBox("empresa",cdo.getColValue("empresa"),false,false,true,5)%>
								<%=fb.textBox("nombreEmpresa",cdo.getColValue("nombreEmpresa"),false,false,true,80)%>
							</td>
						</tr>
                        
                        <tr class="TextRow01">
							<td align="right"><cellbytelabel>Categor&iacute;a</cellbytelabel></td>
							<td>
								<%=fb.intBox("categoria",cdo.getColValue("categoria"),false,false,true,5)%>
								<%=fb.textBox("categoriaDesc",cdo.getColValue("categoriaDesc"),false,false,true,10)%>
                                
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                Poliza&nbsp;<%=fb.textBox("poliza",cdo.getColValue("poliza"),false,false,true,15)%>
                                
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                Certificado&nbsp;&nbsp;<%=fb.textBox("certificado",cdo.getColValue("certificado"),false,false,true,21)%>
							</td>
						</tr>
                        
                        <tr class="TextRow01">
							<td align="right"><cellbytelabel>Fecha</cellbytelabel></td>
                            <td>
                               <jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha")%>" />
								</jsp:include>
                                
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                <cellbytelabel>Estado</cellbytelabel>
                                <%=fb.select("estado","A=ACTIVA,I=INACTIVO",cdo.getColValue("estado"),false,false,0,"Text10",null,null,null,"")%>
                                
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                <cellbytelabel>Tipo Beneficio</cellbytelabel><!-- C=CONVENIO, -->
                                <%=fb.select("tipo_beneficio","S=SOLICITUD",cdo.getColValue("tipo_beneficio"),false,false,0,"Text10",null,null,null,"")%>
                                
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                Tipo Poliza
                                <%=fb.select(ConMgr.getConnection(),"select codigo, nombre||' - '||codigo from tbl_adm_tipo_poliza where nombre not like 'NO USAR%' order by 2","tipo_poliza",cdo.getColValue("tipo_poliza"),false,false,0, "text10", "", "onChange=loadXML('../xml/tipo_plan_x_poliza"+UserDet.getUserId()+".xml','tipo_plan','','VALUE_COL','LABEL_COL',this.value,'KEY_COL','');","","S")%>
                                
                                
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                Tipo Plan
                                <%=fb.select("tipo_plan","","",false,false,0,null,null,null)%>
								<script>
								loadXML('../xml/tipo_plan_x_poliza<%=UserDet.getUserId()%>.xml','tipo_plan','<%=cdo.getColValue("tipo_plan")%>','VALUE_COL','LABEL_COL','<%=cdo.getColValue("tipo_poliza")%>','KEY_COL','');
								</script>
                                
                            </td>
						</tr>

                        <tr class="TextRow01">
                          <td align="right">Montos</td>
                          <td>
                            &nbsp;&nbsp;Cl&iacute;nica&nbsp;<%=fb.select("tipo_val_cli","M=$,P=%",cdo.getColValue("tipo_val_cli"))%>
                            <%=fb.decBox("monto_cli",cdo.getColValue("monto_cli"),false,false,viewMode,5,5.2)%>
                            &nbsp;<%=fb.select("tipo_cob_cli","E=Evento,D=Diario",cdo.getColValue("tipo_cob_cli"))%>
                            
                            &nbsp;&nbsp;Paciente&nbsp;<%=fb.select("tipo_val_pac","M=$,P=%",cdo.getColValue("tipo_val_pac"))%>
                            <%=fb.decBox("monto_pac",cdo.getColValue("monto_pac"),false,false,viewMode,5,5.2)%>
                            &nbsp;<%=fb.select("tipo_cob_pac","E=Evento,D=Diario",cdo.getColValue("tipo_cob_pac"))%>
                            
                            &nbsp;&nbsp;Empresa&nbsp;<%=fb.select("tipo_val_emp","M=$,P=%",cdo.getColValue("tipo_val_emp"))%>
                            <%=fb.decBox("monto_emp",cdo.getColValue("monto_emp"),false,false,viewMode,5,5.2)%>
                            &nbsp;<%=fb.select("tipo_cob_emp","E=Evento,D=Diario",cdo.getColValue("tipo_cob_emp"))%>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pago Paciente
                            &nbsp;<%=fb.select("tipo_pago_pac","CO=Copago, CS=Coaseguro",cdo.getColValue("tipo_pago_pac"))%>
                            
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pago Empresa
                            &nbsp;<%=fb.select("tipo_pago_pac","P=Perdiem",cdo.getColValue("tipo_pago_pac"))%>
                            
                          </td>
                        </tr>
                        
                        <tr class="TextRow01">
                          <td align="right">Observaci&oacute;n</td>
                          <td>
                            <%=fb.textarea("observacion",cdo.getColValue("observacion"),false,false,false,100,2, 2000)%>
                          </td>
                        </tr>

						</table>
					</td>
				</tr>
	
				<tr class="TextRow02">
					<td align="right">
						<cellbytelabel>Opciones de Guardar</cellbytelabel>:
						<%=fb.radio("saveOption","N")%><cellbytelabel>Crear Otro</cellbytelabel>
						<%=fb.radio("saveOption","O",true,false,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
						<%=fb.radio("saveOption","C")%><cellbytelabel>Cerrar</cellbytelabel>
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:closeWin()\"")%>
					</td>
				</tr>
                <%=fb.formEnd(true)%>


				</table>

            </div>
<!-- TAB0 DIV END HERE-->

            <div class="dhtmlgoodies_aTab" data-tabsrc="../admision/sol_ben_new_proc_diag.jsp?mode=<%=mode%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>&id=<%=secuencia%>" data-tabframe="ifSolBenProcDiag">
					
                <table width="100%" cellpadding="1" cellspacing="0">
                    <tr class="TextRow02">
                        <td colspan="2">
                        <iframe id="ifSolBenProcDiag" name="ifSolBenProcDiag" width="100%" height="600" scrolling="yes" frameborder="0" src=""></iframe>
                    </td>
                    </tr>
                </table>
            </div>
            
            
            <div class="dhtmlgoodies_aTab" data-tabsrc="../admision/sol_ben_new_coberturas.jsp?mode=<%=mode%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>&id=<%=secuencia%>" data-tabframe="ifSolBenCob">
					
                <table width="100%" cellpadding="1" cellspacing="0">
                    <tr class="TextRow02">
                        <td colspan="2">
                        <iframe id="ifSolBenCob" name="ifSolBenCob" width="100%" height="600" scrolling="yes" frameborder="0" src=""></iframe>
                    </td>
                    </tr>
                </table>
            </div>
            
            <!-- Exclusiones -->
            <div class="dhtmlgoodies_aTab" data-tabsrc="../admision/sol_ben_new_exclusiones.jsp?mode=<%=mode%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>&id=<%=secuencia%>" data-tabframe="ifSolBenExcl">
					
                <table width="100%" cellpadding="1" cellspacing="0">
                    <tr class="TextRow02">
                        <td colspan="2">
                        <iframe id="ifSolBenExcl" name="ifSolBenExcl" width="100%" height="600" scrolling="yes" frameborder="0" src=""></iframe>
                    </td>
                    </tr>
                </table>
            </div>
            
            <!-- No cubiertos -->
            <div class="dhtmlgoodies_aTab" data-tabsrc="../admision/sol_ben_new_no_cobiertos.jsp?mode=<%=mode%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>&id=<%=secuencia%>" data-tabframe="ifSolBenNoCob">
					
                <table width="100%" cellpadding="1" cellspacing="0">
                    <tr class="TextRow02">
                        <td colspan="2">
                        <iframe id="ifSolBenNoCob" name="ifSolBenNoCob" width="100%" height="600" scrolling="yes" frameborder="0" src=""></iframe>
                    </td>
                    </tr>
                </table>
            </div>


<!-- MAIN DIV END HERE -->
</div>

<script>
<%
String tabLabel = "'Generales'"; //'Exclusiones','No Cobiertos'
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Diagnósticos','Configuración'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>

			</td>
		</tr>
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
    
	if (tab.equals("0")) //CONVENIO
	{
		cdo = new CommonDataObject();
        
        System.out.println("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "+request.getParameter("fecha"));

        cdo.setTableName("tbl_ase_convenio");
        cdo.addColValue("pac_id",request.getParameter("pac_id"));
        cdo.addColValue("admision",request.getParameter("admision"));
        cdo.addColValue("observacion",request.getParameter("observacion"));
        cdo.addColValue("empresa",request.getParameter("empresa"));
        cdo.addColValue("categoria",request.getParameter("categoria"));
        cdo.addColValue("poliza",request.getParameter("poliza"));
        cdo.addColValue("certificado",request.getParameter("certificado"));
        cdo.addColValue("fecha",request.getParameter("fecha"));
        cdo.addColValue("estado",request.getParameter("estado"));
        cdo.addColValue("tipo",request.getParameter("tipo_beneficio"));
        cdo.addColValue("tipo_plan",request.getParameter("tipo_plan"));
        cdo.addColValue("tipo_poliza",request.getParameter("tipo_poliza"));
        cdo.addColValue("compania",compania);
        cdo.addColValue("monto_cli",request.getParameter("monto_cli"));
        cdo.addColValue("monto_pac",request.getParameter("monto_pac"));
        cdo.addColValue("monto_emp",request.getParameter("monto_emp"));
        cdo.addColValue("tipo_val_cli",request.getParameter("tipo_val_cli"));
        cdo.addColValue("tipo_val_pac",request.getParameter("tipo_val_pac"));
        cdo.addColValue("tipo_val_emp",request.getParameter("tipo_val_emp"));
        cdo.addColValue("tipo_cob_cli",request.getParameter("tipo_cob_cli"));
        cdo.addColValue("tipo_cob_emp",request.getParameter("tipo_cob_emp"));
        cdo.addColValue("tipo_pago_pac",request.getParameter("tipo_pago_pac"));
        cdo.addColValue("tipo_pago_emp",request.getParameter("tipo_pago_emp"));
        
        ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
        if (mode.equalsIgnoreCase("add")){
            cdo.setAutoIncCol("id");
		    cdo.addPkColValue("id","");
            cdo.addColValue("fecha_creacion", cDateTime);
            cdo.addColValue("usuario_creacion",cUserName);
            cdo.addColValue("fecha_modificacion", cDateTime);
            cdo.addColValue("usuario_modificacion",cUserName);
		    
            SQLMgr.insert(cdo);
		    secuencia = SQLMgr.getPkColValue("id");
        }else{
            cdo.addColValue("fecha_modificacion", cDateTime);
            cdo.addColValue("usuario_modificacion",cUserName);
            
            cdo.setWhereClause("id="+secuencia+" and pac_id = "+request.getParameter("pac_id")+" and admision = "+request.getParameter("admision"));
            SQLMgr.update(cdo);
        }
        
		ConMgr.clearAppCtx(null);
	}
	
%>
<html>
<head>
<script>
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&empresa=<%=empresa%>&secuencia=<%=secuencia%>&tipo_poliza=<%=tipoPoliza%>&tipo_plan=<%=tipoPlan%>&nombreEmpresa=<%=nombreEmpresa%>&certificado=<%=certificado%>&poliza=<%=poliza%>&categoria=<%=categoria%>&categoriaDesc=<%=categoriaDesc%>&pac_id=<%=pacId%>&admision=<%=noAdmision%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>