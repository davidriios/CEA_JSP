<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" 		scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" 		scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" 	scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" 		scope="page" 		class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" 		scope="page" 		class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" 				scope="page" 		class="issi.admin.FormBean" />
<jsp:useBean id="cdo" 			scope="page" 		class="issi.admin.CommonDataObject" />
<jsp:useBean id="htTar" 		scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htNaTar" 	scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htEduFN" 	scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htEduNFN"	scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htELP" 		scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCer" 		scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCon" 		scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htORq" 		scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htACu" 		scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htCmn" 		scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================
800033	VER LISTA DE TIPO DE UNIFORME
800034	IMPRIMIR LISTA DE TIPO DE UNIFORME
800035	AGREGAR TIPO DE UNIFORME
800036	MODIFICAR TIPO DE UNIFORME
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList alTar = new ArrayList();
ArrayList alNaTar = new ArrayList();
ArrayList alEduFN = new ArrayList();
ArrayList alEduNFN = new ArrayList();
ArrayList alELP = new ArrayList();
ArrayList alCer = new ArrayList();
ArrayList alCon = new ArrayList();
ArrayList alORq = new ArrayList();
ArrayList alACu = new ArrayList();

String sql = "";
String mode = request.getParameter("mode");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fg = request.getParameter("fg");

if(fg==null) fg="";
if(change==null) change="";
int indTab = 0;
if(request.getParameter("indTab")!=null) indTab = Integer.parseInt(request.getParameter("indTab"));

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		cdo.addColValue("codigo","");		
	}
	else
	{
		if (id == null) throw new Exception("El Tipo de Uniforme no es válido. Por favor intente nuevamente!");

		String key = "";

		sql = "SELECT compania, codigo, denominacion, estado, NVL(nombre_corto, '') nombre_corto, NVL(tipo_puesto,'') tipo_puesto, NVL(gasto_rep,'N') gasto_rep, NVL(monto_gastorep,'') monto_gastorep, NVL(resumen,' ') resumen, NVL(descripcion,' ') descripcion, NVL(supervisar,'') supervisar,NVL(supervisado,'') supervisado, nvl(experiencia,' ') experiencia, nvl(naturaleza_tareas,' ') naturaleza_tareas, nvl(educacion_formal,'') educacion_formal, nvl(educacion_noformal,'') educacion_noformal, nvl(conocimiento,'') conocimiento, nvl(habilidad,'') habilidad, nvl(destreza,'') destreza, nvl(licencia,'') licencia, nvl(certificado,'') certificado, nvl(salario_mes,'') salario_mes, nvl(condiciones,'') condiciones, nvl(otros_requisitos,'') otros_requisitos, nvl(aspectos_cuantitativos,'') aspectos_cuantitativos, categoria as categoria, nvl(tipo_uniforme,0) tipo_uniforme, nvl(dias_vacacion,0) dias_vacacion, nvl(marcar,'') marcar, nvl(derecho_permiso_ejecutivo,'') permiso, nvl(cantdias_permiso_ejecutivo,'') cantDias, nvl(firmar_carta_trabajo,'') firmar from tbl_pla_cargo where compania = "+session.getAttribute("_companyId")+" and codigo='"+id+"'";
		cdo = SQLMgr.getData(sql);
		if(change.equals("")){
			sql = "select cargo, codigo, descripcion from tbl_pla_tarea_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";

			htTar.clear();
			htNaTar.clear();
			htEduFN.clear();
			htEduNFN.clear();
			htELP.clear();
			htCer.clear();
			htCon.clear();
			htORq.clear();
			htACu.clear();
			htCmn.clear();

			alTar = SQLMgr.getDataList(sql);
			htTar = CmnMgr.putLineNumber(htTar,alTar);
			
			sql = "select cargo, codigo, descripcion from tbl_pla_naturaleza_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";
			alNaTar = SQLMgr.getDataList(sql);
			htNaTar = CmnMgr.putLineNumber(htNaTar,alNaTar);
			
			sql = "select cargo, codigo, descripcion from tbl_pla_educacion_fn_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";
			alEduFN = SQLMgr.getDataList(sql);
			htEduFN = CmnMgr.putLineNumber(htEduFN,alEduFN);
			
			sql = "select cargo, codigo, descripcion from tbl_pla_educacion_nofn_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";
			alEduNFN = SQLMgr.getDataList(sql);
			htEduNFN = CmnMgr.putLineNumber(htEduNFN,alEduNFN);
			
			sql = "select cargo, codigo, descripcion from tbl_pla_experiencia_lp_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";
			alELP = SQLMgr.getDataList(sql);
			htELP = CmnMgr.putLineNumber(htELP,alELP);
			
			sql = "select cargo, codigo, descripcion from tbl_pla_certificado_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";
			alCer = SQLMgr.getDataList(sql);
			htCer = CmnMgr.putLineNumber(htCer,alCer);
			
			sql = "select cargo, codigo, descripcion from tbl_pla_conocimiento_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";
			alCon = SQLMgr.getDataList(sql);
			htCon = CmnMgr.putLineNumber(htCon,alCon);
			
			sql = "select cargo, codigo, descripcion from tbl_pla_otro_requisito_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";
			alORq = SQLMgr.getDataList(sql);
			htORq = CmnMgr.putLineNumber(htORq,alORq);
			
			sql = "select cargo, codigo, descripcion, valor from tbl_pla_aspecto_cu_ca where compania = "+session.getAttribute("_companyId")+" and cargo='"+id+"'";
			alACu = SQLMgr.getDataList(sql);
			htACu = CmnMgr.putLineNumber(htACu,alACu);
		}		
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Administración - '+document.title;

function checkCode(obj)
{
	return duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_pla_cargo','codigo=\''+obj.value+'\'','<%=cdo.getColValue("codigo")%>');
}
function doAction()
{
}
function removeItem1(fName,k)
{
	var rem = eval('document.'+fName+'.rem1'+k).value;
	eval('document.'+fName+'.remove1'+k).value = rem;
	setBAction(fName,rem);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CREAR CARGO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
			<div id="dhtmlgoodies_tabView1">
        <!--GENERALES TAB0-->
				<!-- G A R G O -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			<%fb.appendJsValidation("if(document.form0.baction.value!='Guardar')return true;");%>
			<%=fb.hidden("mode",mode)%> 
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("indTab","0")%>
			<%=fb.hidden("tipo_uniforme","")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Generales de Cargo</td>
			</tr>
			<tr class="TextRow01">
				<td width="20%" align="right">Nombre Corto</td>
				<td width="30%"><%=fb.textBox("nombre_corto",cdo.getColValue("nombre_corto"),false,false,false,25,20,null,null,"")%></td>
				<td width="25%" align="right">C&oacute;digo</td>
				<td width="25%"><%=fb.textBox("codigo",cdo.getColValue("codigo"),false,false,true,15,12,null,null,"onBlur=\"javascript:checkCode(this)\"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Denominaci&oacute;n</td>
				<td><%=fb.textBox("denominacion",cdo.getColValue("denominacion"),true,false,false,40,null,null,"")%></td>
				<td align="right">Gasto Representaci&oacute;n</td>
				<td><%=fb.select("gasto_rep","N=No,S=Si",cdo.getColValue("gasto_rep"))%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Salario Base</td>
				<td><%=fb.decBox("salario_mes",cdo.getColValue("salario_mes"),false,false,false,10,10.2,null,null,"")%></td>
				<td align="right">Monto Gatos Rep.</td>
				<td><%=fb.decBox("monto_gastorep",cdo.getColValue("monto_gastorep"),false,false,false,10,10.2,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right"></td>
				<td><%//=fb.select(ConMgr.getConnection(),"select codigo, descripcion from tbl_pla_tipo_puesto order by descripcion","tipo_puesto",cdo.getColValue("tipo_puesto"))%></td>
				<td align="right">D&iacute;as de Vacaciones</td>
				<td><%=fb.intBox("dias_vacacion",cdo.getColValue("dias_vacacion"),false,false,false,5,2,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				
			<td colspan="3" align="right">Estado</td>
				<td><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"))%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Certificado</td>
				<td><%=fb.textBox("certificado",cdo.getColValue("certificado"),false,false,false,20,null,null,"")%></td>
				 <td align="right">Categoria</td>
				<td><%=fb.intBox("categoria",cdo.getColValue("categoria"),false,false,false,5,2,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Derecho de Permiso Ejecutivo</td>
				<td><%=fb.checkbox("permiso","S",(cdo.getColValue("permiso") != null && cdo.getColValue("permiso").equalsIgnoreCase("S")),false)%></td>
				 <td align="right">Cantidad de Dias de Permiso Ejecutivo</td>
				<td><%=fb.intBox("cantDias",cdo.getColValue("cantDias"),false,false,false,5,2,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Marcar </td>
				<td><%=fb.checkbox("marcar","S",(cdo.getColValue("marcar") != null && cdo.getColValue("marcar").equalsIgnoreCase("S")),false)%></td>
				 <td align="right">Firmar Carta de Trabajo</td>
				<td><%=fb.checkbox("firmar","S",(cdo.getColValue("firmar") != null && cdo.getColValue("firmar").equalsIgnoreCase("S")),false)%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Resumen</td>
				<td colspan="3"><%=fb.textBox("resumen",cdo.getColValue("resumen"),false,false,false,100,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Descripci&oacute;n</td>
				<td colspan="3"><%=fb.textBox("descripcion",cdo.getColValue("descripcion"),false,false,false,100,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Habilidades</td>
				<td colspan="3"><%=fb.textBox("habilidad",cdo.getColValue("habilidad"),false,false,false,100,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Destreza</td>
				<td colspan="3"><%=fb.textBox("destreza",cdo.getColValue("destreza"),false,false,false,100,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Licencia</td>
				<td colspan="3"><%=fb.textBox("licencia",cdo.getColValue("licencia"),false,false,false,100,null,null,"")%></td>
			</tr>
			<tr class="TextRow01">
				<td align="right">Condiciones</td>
				<td colspan="3"><%=fb.textBox("condiciones",cdo.getColValue("condiciones"),false,false,false,100,null,null,"")%></td>
			</tr>
			<tr class="TextHeader">
				<td align="right">Supervici&oacute;n</td>
				<td colspan="3">&nbsp;</td>	
			</tr>
			<tr class="TextRow01">
				<td align="right">Brindada</td>
				<td colspan="3"><%=fb.textBox("brindada",cdo.getColValue("supervisar"),false,false,false,100,null,null,"")%></td>	
			</tr>
			<tr class="TextRow01">
				<td align="right">Recibida</td>
				<td colspan="3"><%=fb.textBox("recibida",cdo.getColValue("supervisado"),false,false,false,100,null,null,"")%></td>
			</tr>							
			<tr class="TextRow02">
				<td colspan="4" align="right">
				<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<%//fb.appendJsValidation("if(error>0)doAction();");%>
			<%=fb.formEnd(true)%>
			
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<!-- T A R E A S   Y   N A T U R A L E Z A   D E   L A S   T A R E A S -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> 
			<%fb.appendJsValidation("if(document.form1.baction.value!='Guardar')return true;");%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("indTab","1")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("fg",fg)%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextPanel">
				<td width="10%" align="right">Cargo:&nbsp;</td>
				<td width="*" colspan="2">&nbsp;<%=cdo.getColValue("codigo")%>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("denominacion")%></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Tareas</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader">
							<td width="15%" align="center">C&oacute;digo</td>
							<td width="70%" align="center">Descripci&oacute;n</td>
							<td width="15%" align="center"><%=fb.submit("addCmn1","Agregar.",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						</tr>
				<%
				String key = "";
				alTar = new ArrayList();
				if(htTar.size()!=0) alTar = CmnMgr.reverseRecords(htTar);
				for (int i=0; i<htTar.size(); i++) {
					key = alTar.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htTar.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%><%=fb.hidden("remove"+i,"")%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td align="center"><%=fb.textBox("codigo_cmn1"+i,cdo_.getColValue("codigo"),true,false,true,10,null,null,"")%></td>
<td align="center"><%=fb.textBox("descripcion_cmn1"+i,cdo_.getColValue("descripcion"),true,false,false,90,null,null,"")%></td>
<td align="center"><%=fb.submit("rem"+i,"Eliminar.",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>

</tr>
						<%=fb.hidden("cod_t"+i,key)%>
				<%
				}
				%>
				<%=fb.hidden("sizeCmn1",""+htTar.size())%>
				</table></td></tr></table></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Naturaleza de las Tareas</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader">
							<td width="15%" align="center">C&oacute;digo</td>
							<td width="70%" align="center">Descripci&oacute;n</td>
							<td width="15%" align="center"><%=fb.submit("addCmn2","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						</tr>
				<%
				alNaTar = new ArrayList();
				if(htNaTar.size()!=0) alNaTar = CmnMgr.reverseRecords(htNaTar);
				for (int i=0; i<htNaTar.size(); i++) {
					key = alNaTar.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htNaTar.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
<%=fb.hidden("remove1"+i,"")%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td align="center"><%=fb.textBox("codigo_cm2"+i,cdo_.getColValue("codigo"),true,false,true,10,null,null,"")%></td>
<td align="center"><%=fb.textBox("descripcion_cmn2"+i,cdo_.getColValue("descripcion"),true,false,false,90,null,null,"")%></td>
<td align="center"><%=fb.submit("rem1"+i,"Eliminar",true,false,null,null,"onClick=\"javascript:removeItem1('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
						<%=fb.hidden("cod_nt",key)%>
				<%
				}
				//fb.appendJsValidation("if(error>0)doAction();");
				%>
				<%=fb.hidden("sizeCmn2",""+htNaTar.size())%>
				</table></td></tr></table></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4"></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<!-- E D U C A C I O N -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document.form2.baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("indTab","2")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextPanel">
				<td width="10%" align="right">Cargo:&nbsp;</td>
				<td width="*" colspan="2">&nbsp;<%=cdo.getColValue("codigo")%>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("denominacion")%></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Educaci&oacute;n Formal Necesaria</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader">
							<td width="15%" align="center">C&oacute;digo</td>
							<td width="70%" align="center">Descripci&oacute;n</td>
							<td width="15%" align="center"><%=fb.submit("addCmn1","Agregar.",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						</tr>
				<%
				key = "";
				alEduFN = new ArrayList();
				if(htEduFN.size()!=0) alEduFN = CmnMgr.reverseRecords(htEduFN);
				for (int i=0; i<htEduFN.size(); i++) {
					key = alEduFN.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htEduFN.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
<%=fb.hidden("remove"+i,"")%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td align="center"><%=fb.textBox("codigo_cmn1"+i,cdo_.getColValue("codigo"),true,false,true,10,null,null,"")%></td>
<td align="center"><%=fb.textBox("descripcion_cmn1"+i,cdo_.getColValue("descripcion"),true,false,false,90,null,null,"")%></td>
<td align="center"><%=fb.submit("rem"+i,"Eliminar.",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
<%=fb.hidden("cod_t"+i,key)%>
				<%
				}
				//fb.appendJsValidation("if(error>0)doAction();");
				%>
				<%=fb.hidden("sizeCmn1",""+htEduFN.size())%>
				</table></td></tr></table></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Educaci&oacute;n No Formal Necesaria</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader">
							<td width="15%" align="center">C&oacute;digo</td>
							<td width="70%" align="center">Descripci&oacute;n</td>
							<td width="15%" align="center"><%=fb.submit("addCmn2","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						</tr>
				<%
				alEduNFN = new ArrayList();
				if(htEduNFN.size()!=0) alEduNFN = CmnMgr.reverseRecords(htEduNFN);
				for (int i=0; i<htEduNFN.size(); i++) {
					key = alEduNFN.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htEduNFN.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
<%=fb.hidden("remove1"+i,"")%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
<td align="center"><%=fb.textBox("codigo_cm2"+i,cdo_.getColValue("codigo"),true,false,true,10,null,null,"")%></td>
<td align="center"><%=fb.textBox("descripcion_cmn2"+i,cdo_.getColValue("descripcion"),true,false,false,90,null,null,"")%></td>
<td align="center"><%=fb.submit("rem1"+i,"Eliminar",true,false,null,null,"onClick=\"javascript:removeItem1('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
						<%=fb.hidden("cod_nt",key)%>
						<%=fb.hidden("sizeCmn2",""+htEduNFN.size())%>
				<%
				}
				fb.appendJsValidation("if(error>0)doAction();");
				%>
				
				</table></td></tr></table></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4"></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%><%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<!-- E X P E R I E N C I A -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document.form3.baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("indTab","3")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("sizeCmn1",""+htELP.size())%>
			<%=fb.hidden("sizeCmn2",""+htCer.size())%>
			<%=fb.hidden("fg",fg)%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextPanel">
				<td width="10%" align="right">Cargo:&nbsp;</td>
				<td width="*" colspan="2">&nbsp;<%=cdo.getColValue("codigo")%>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("denominacion")%></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Experiencia Laboral Previa</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader"  align="center">
							<td width="15%">C&oacute;digo</td>
							<td width="70%">Descripci&oacute;n</td>
							<td width="15%"><%=fb.submit("addCmn1","Agregar.",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						</tr>
				<%
				key = "";
				alELP = new ArrayList();
				if(htELP.size()!=0) alELP = CmnMgr.reverseRecords(htELP);
				for (int i=0; i<htELP.size(); i++) {
					key = alELP.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htELP.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
<%=fb.hidden("remove"+i,"")%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
<td><%=fb.textBox("codigo_cmn1"+i,cdo_.getColValue("codigo"),true,false,true,10,null,null,"")%></td>
<td><%=fb.textBox("descripcion_cmn1"+i,cdo_.getColValue("descripcion"),true,false,false,90,2000,null,null,"")%></td>
<td><%=fb.submit("rem"+i,"Eliminar.",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
						<%=fb.hidden("cod_t"+i,key)%>
				<%
				}
				//fb.appendJsValidation("if(error>0)doAction();");
				%>
				</table></td></tr></table></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Certificados Necesarios</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader">
							<td width="15%" align="center">C&oacute;digo</td>
							<td width="70%" align="center">Descripci&oacute;n</td>
							<td width="15%" align="center"><%=fb.submit("addCmn2","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						</tr>
				<%
				alCer = new ArrayList();
				if(htCer.size()!=0) alCer = CmnMgr.reverseRecords(htCer);
				for (int i=0; i<htCer.size(); i++) {
					key = alCer.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htCer.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>	
<%=fb.hidden("remove1"+i,"")%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"  align="center">
<td><%=fb.textBox("codigo_cm2"+i,cdo_.getColValue("codigo"),true,false,true,10,3,null,null,"")%></td>
<td><%=fb.textBox("descripcion_cmn2"+i,cdo_.getColValue("descripcion"),true,false,false,90,2000,null,null,"")%></td>
<td><%=fb.submit("rem1"+i,"Eliminar",true,false,null,null,"onClick=\"javascript:removeItem1('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
						<%=fb.hidden("cod_nt",key)%>
				<%
				}
				fb.appendJsValidation("if(error>0)doAction();");
				%>
				</table></td></tr></table></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4"></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<!-- C O N O C I M I E N T O   Y   O T R O S -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%fb.appendJsValidation("if(document.form4.baction.value!='Guardar')return true;");%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("indTab","4")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextPanel">
				<td width="10%" align="right">Cargo:&nbsp;</td>
				<td width="*" colspan="2">&nbsp;<%=cdo.getColValue("codigo")%>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("denominacion")%></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Conocimientos</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader">
							<td width="15%" align="center">C&oacute;digo</td>
							<td width="70%" align="center">Descripci&oacute;n</td>
							<td width="15%" align="center"><%=fb.submit("addCmn1","Agregar.",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						</tr>
				<%
				key = "";
				alCon = new ArrayList();
				if(htCon.size()!=0) alCon = CmnMgr.reverseRecords(htCon);
				for (int i=0; i<htCon.size(); i++) {
					key = alCon.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htCon.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
<%=fb.hidden("remove"+i,"")%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')"  align="center">
<td><%=fb.textBox("codigo_cmn1"+i,cdo_.getColValue("codigo"),true,false,true,10,3,null,null,"")%></td>
<td><%=fb.textBox("descripcion_cmn1"+i,cdo_.getColValue("descripcion"),true,false,false,90,200,null,null,"")%></td>
<td><%=fb.submit("rem"+i,"Eliminar.",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
						<%=fb.hidden("cod_t"+i,key)%>
				<%
				}
				//fb.appendJsValidation("if(error>0)doAction();");
				%>
				<%=fb.hidden("sizeCmn1",""+htCon.size())%>
				</table></td></tr></table></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Otros Requisitos</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader">
							<td width="15%" align="center">C&oacute;digo</td>
							<td width="70%" align="center">Descripci&oacute;n</td>
							<td width="15%" align="center"><%=fb.submit("addCmn2","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%><%//=fb.submit("addCmn2","Agregar",true,false)%></td>
						</tr>
				<%
				alORq = new ArrayList();
				if(htORq.size()!=0) alORq = CmnMgr.reverseRecords(htORq);
				for (int i=0; i<htORq.size(); i++) {
					key = alORq.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htORq.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
						<%=fb.hidden("remove1"+i,"")%>
<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" align="center">
<td><%=fb.textBox("codigo_cm2"+i,cdo_.getColValue("codigo"),true,false,true,10,null,null,"")%></td>
<td><%=fb.textBox("descripcion_cmn2"+i,cdo_.getColValue("descripcion"),true,false,false,90,2000,null,null,"")%></td>
<td><%=fb.submit("rem1"+i,"Eliminar",true,false,null,null,"onClick=\"javascript:removeItem1('"+fb.getFormName()+"',"+i+")\"")%></td>
</tr>
				<%=fb.hidden("cod_nt",key)%>
				<%
				}
				fb.appendJsValidation("if(error>0)doAction();");
				%>
				<%=fb.hidden("sizeCmn2",""+htORq.size())%>
				</table></td></tr></table></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4"></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
<!-- A S P E C T O S -->
<div class="dhtmlgoodies_aTab">
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%> <%=fb.hidden("mode",mode)%>
			<%fb.appendJsValidation("if(document.form5.baction.value!='Guardar')return true;");%>
			<%=fb.hidden("id",id)%>
			<%=fb.hidden("indTab","5")%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextPanel">
				<td width="10%" align="right">Cargo:&nbsp;</td>
				<td width="*" colspan="2">&nbsp;<%=cdo.getColValue("codigo")%>&nbsp;&nbsp;&nbsp;<%=cdo.getColValue("denominacion")%></td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4">Aspectos Cuantitativos</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4"><table align="center" width="90%" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0"><tr><td><table align="center" width="100%" cellpadding="0" cellspacing="1" class="TableBorderWhite">
						<tr class="TextHeader">
							<td width="15%" align="center">C&oacute;digo</td>
							<td width="55%" align="center">Descripci&oacute;n</td>
							<td width="15%" align="center">Valor</td>
							<td width="15%" align="center"><%=fb.submit("addCmn1","Agregar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
						</tr>
				<%
				key = "";
				alACu = new ArrayList();
				if(htACu.size()!=0) alACu = CmnMgr.reverseRecords(htACu);
				for (int i=0; i<htACu.size(); i++) {
					key = alACu.get(i).toString();
					CommonDataObject cdo_ = (CommonDataObject) htACu.get(key);
					String color = "TextRow02";
					if (i % 2 == 0) color = "TextRow01";
				%>
				<%=fb.hidden("remove"+i,"")%>
						<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
							<td align="center"><%=fb.textBox("codigo"+i,cdo_.getColValue("codigo"),true,false,true,10,3,null,null,"")%></td>
							<td align="center"><%=fb.textBox("descripcion"+i,cdo_.getColValue("descripcion"),true,false,false,70,2000,null,null,"")%></td>
							<td align="center"><%=fb.textBox("valor"+i,cdo_.getColValue("valor"),false,false,false,10,100,null,null,"")%></td>
							<td align="center"><%=fb.submit("rem"+i,"Eliminar",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%></td>
						</tr>
						<%=fb.hidden("cod_t"+i,key)%>
				<%
				}
				fb.appendJsValidation("if(error>0)doAction();");
				%>
				<%=fb.hidden("sizeCmn1",""+htACu.size())%>
				</table></td></tr></table></td>
			</tr>
			<tr class="TextRow01">
				<td colspan="4">&nbsp;</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="4"></td>
			</tr>
			<tr class="TextRow02">
				<td colspan="4" align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
			</tr>
			<tr>
				<td colspan="4">&nbsp;</td>
			</tr>
			<%=fb.formEnd(true)%>
			<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table></td>
</table>
</div>
</div>
<script type="text/javascript">
<%
String tabLabel = "'Cargos'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Tareas y Natur.','Educaci&oacute;n','Experiencia','Conoc. y Otros','Aspectos'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=indTab%>,'100%','');

</script>
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
	String companyId = (String) session.getAttribute("_companyId");
	String del = "0";
	String baction = request.getParameter("baction");
	String tableName1 = "", tableName2 = "";
	id = request.getParameter("id");
	if(indTab==0){
		tableName1 = "tbl_pla_cargo";
	} else if(indTab==1){
		tableName1 = "tbl_pla_tarea_ca";
		tableName2 = "tbl_pla_naturaleza_ca";
	} else if(indTab==2){
		tableName1 = "tbl_pla_educacion_fn_ca";
		tableName2 = "tbl_pla_educacion_nofn_ca";
	} else if(indTab==3){
		tableName1 = "tbl_pla_experiencia_lp_ca";
		tableName2 = "tbl_pla_certificado_ca";
	} else if(indTab==4){
		tableName1 = "tbl_pla_conocimiento_ca";
		tableName2 = "tbl_pla_otro_requisito_ca";
	} else if(indTab==5){
		tableName1 = "tbl_pla_aspecto_cu_ca";
	}
	
	htCmn.clear();
	cdo = new CommonDataObject();
	cdo.addColValue("compania",companyId);
	if(indTab==0){
		cdo.setTableName(tableName1);
		cdo.addColValue("nombre_corto",request.getParameter("nombre_corto"));
		/*cdo.addColValue("codigo",request.getParameter("codigo"));*/
		cdo.setAutoIncCol("codigo");
		cdo.setAutoIncWhereClause("compania = "+companyId);
		cdo.addPkColValue("codigo","");
		cdo.addColValue("denominacion",request.getParameter("denominacion"));
		cdo.addColValue("gasto_rep",request.getParameter("gasto_rep"));
		cdo.addColValue("salario_mes",request.getParameter("salario_mes"));
		cdo.addColValue("monto_gastorep",request.getParameter("monto_gastorep"));
		cdo.addColValue("dias_vacacion",request.getParameter("dias_vacacion"));
		cdo.addColValue("tipo_uniforme",request.getParameter("tipo_uniforme"));
		cdo.addColValue("resumen",request.getParameter("resumen"));
		cdo.addColValue("descripcion",request.getParameter("descripcion"));
		cdo.addColValue("habilidad",request.getParameter("habilidad"));
		cdo.addColValue("destreza",request.getParameter("destreza"));
		cdo.addColValue("licencia",request.getParameter("licencia"));
		cdo.addColValue("condiciones",request.getParameter("condiciones"));
		cdo.addColValue("supervisar",request.getParameter("brindada"));
		cdo.addColValue("supervisado",request.getParameter("recibida"));
		//cdo.addColValue("tipo_puesto",request.getParameter("tipo_puesto"));
		cdo.addColValue("estado",request.getParameter("estado"));
		cdo.addColValue("certificado",request.getParameter("certificado"));
		cdo.addColValue("categoria",request.getParameter("categoria"));
		if(request.getParameter("marcar")!=null && request.getParameter("marcar").trim().equals("S"))//marcar
		cdo.addColValue("marcar","S");
		if(request.getParameter("permiso")!=null && request.getParameter("permiso").trim().equals("S"))
		cdo.addColValue("derecho_permiso_ejecutivo","S");
		cdo.addColValue("cantdias_permiso_ejecutivo",request.getParameter("cantDias"));
		if(request.getParameter("firmar")!=null && request.getParameter("firmar").trim().equals("S"))
	  cdo.addColValue("firmar_carta_trabajo","S");

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		if (mode.equalsIgnoreCase("add")){
			cdo.setWhereClause("compania = "+companyId);
	cdo.addColValue("codigo","(SELECT max (to_number(nvl(codigo,'0'))) + 1 FROM tbl_pla_cargo)");
			SQLMgr.insert(cdo);
			id = SQLMgr.getPkColValue("codigo");
		
		} else {
			cdo.setWhereClause("codigo='"+request.getParameter("id")+"' and compania = "+companyId);
			SQLMgr.update(cdo);
		}
		ConMgr.clearAppCtx(null);
	} else if(indTab==1 || indTab==2 || indTab==3 || indTab==4){
		/*==============================================================================================================*/
		/*
			Las tablas tbl_pla_tarea_ca, tbl_pla_naturaleza_ca, tbl_pla_educacion_fn_ca, tbl_pla_educacion_nofn_ca, 
			tbl_pla_experiencia_lp_ca, tbl_pla_certificado_ca, tbl_pla_conocimiento_ca y tbl_pla_otro_requisito_ca tienen
			los mismos campos, por lo que en el mismo bloque puedo hacer lo mismo, solo que cambio el nombre de la tabla a
			utilizar, Hashtable, etc.
		*/
		/*==============================================================================================================*/
		ArrayList alCmn1 = new ArrayList();
		ArrayList alCmn2 = new ArrayList();
		if(indTab==1){htTar.clear();
		htNaTar.clear();}
		if(indTab==2){htEduFN.clear();
		htEduNFN.clear();}
		if(indTab==3){htELP.clear();
		htCer.clear();}
		if(indTab==4){htCon.clear();
		htORq.clear();}
		int sizeCmn1 = 0;
		int sizeCmn2 = 0;
		if(request.getParameter("sizeCmn1")!=null)
		 sizeCmn1 = Integer.parseInt(request.getParameter("sizeCmn1"));
		
		if(request.getParameter("sizeCmn2")!=null)
		 sizeCmn2 = Integer.parseInt(request.getParameter("sizeCmn2"));
		 
		for(int i=0;i<sizeCmn1;i++){
			if(request.getParameter("remove"+i)!=null && request.getParameter("remove"+i).trim().equals("")){
			System.out.println("request.getParameter(remove+i)---"+request.getParameter("remove"+i));
				cdo = new CommonDataObject();
				cdo.setTableName(tableName1);
				
        cdo.setAutoIncCol("codigo");
				cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
				
				cdo.addColValue("compania",companyId);
				cdo.addColValue("cargo",request.getParameter("id"));
				cdo.addColValue("codigo",request.getParameter("codigo_cmn1"+i));
        cdo.addColValue("descripcion",request.getParameter("descripcion_cmn1"+i));
        cdo.setWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
				
				alCmn1.add(cdo);
			} else {
				del = "1";
			}
		}
		if(baction.equalsIgnoreCase("Agregar.")){
			cdo = new CommonDataObject();
			cdo.setTableName(tableName1);
			cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
			cdo.addColValue("compania",companyId);
			cdo.addColValue("cargo",request.getParameter("id"));
			cdo.addColValue("codigo","0");
			cdo.addColValue("descripcion","");
			cdo.setAutoIncCol("codigo");
			alCmn1.add(cdo);
		}
		if (baction.equalsIgnoreCase("Guardar"))
		{
				if (alCmn1.size() == 0)
				{
					cdo = new CommonDataObject();
					cdo.setTableName(tableName1);  
					cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);					
					alCmn1.add(cdo); 
				}
		}
		if(alCmn1.size()>0) htCmn.put(tableName1,alCmn1);
		
		if(indTab==1) htTar = CmnMgr.putLineNumber(htTar,alCmn1);
		else if(indTab==2) htEduFN = CmnMgr.putLineNumber(htEduFN,alCmn1);
		else if(indTab==3) htELP = CmnMgr.putLineNumber(htELP,alCmn1);
		else if(indTab==4) htCon = CmnMgr.putLineNumber(htCon,alCmn1);
		
		for(int i=0;i<sizeCmn2;i++){
			if(request.getParameter("remove1"+i)!=null && request.getParameter("remove1"+i).trim().equals("")){
				cdo = new CommonDataObject();
				cdo.setTableName(tableName2);
				cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
				cdo.addColValue("compania",companyId);
				cdo.addColValue("cargo",request.getParameter("id"));
				cdo.addColValue("codigo",request.getParameter("codigo_cm2"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion_cmn2"+i));
				cdo.setAutoIncCol("codigo");
				cdo.setWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
				alCmn2.add(cdo);
			} else {
				del = "1";
			}
		}
		if(baction.equalsIgnoreCase("Agregar")){
			System.out.println("add 1");
			cdo = new CommonDataObject();
			cdo.setTableName(tableName2);
			cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
			cdo.addColValue("compania",companyId);
			cdo.addColValue("cargo",request.getParameter("id"));
			cdo.addColValue("codigo","0");
			cdo.addColValue("descripcion","");
			cdo.setAutoIncCol("codigo");
			alCmn2.add(cdo);
		}
		if (baction.equalsIgnoreCase("Guardar"))
		{
				if (alCmn2.size() == 0)
				{
					cdo = new CommonDataObject();
					cdo.setTableName(tableName2);  
					cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);					
					alCmn2.add(cdo); 
					
				}
		}
		if(alCmn2.size()>0) htCmn.put(tableName2,alCmn2);

		if(indTab==1) htNaTar = CmnMgr.putLineNumber(htNaTar,alCmn2);
		else if(indTab==2) htEduNFN = CmnMgr.putLineNumber(htEduNFN,alCmn2);
		else if(indTab==3) htCer = CmnMgr.putLineNumber(htCer,alCmn2);
		else if(indTab==4) htORq = CmnMgr.putLineNumber(htORq,alCmn2);
		
			if (baction.equalsIgnoreCase("Guardar")&& htCmn.size()>0){
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.insertMultipleList(htCmn, true, true);
			ConMgr.clearAppCtx(null);
			
		} else {
			System.out.println("del..."+del);
			response.sendRedirect("../rhplanilla/reg_cargo.jsp?mode=edit&change=1&id="+request.getParameter("id")+"&indTab="+indTab+"&fg="+fg);
			return;
		}
	} else if(indTab==5){
		ArrayList alCmn1 = new ArrayList();
		htACu.clear();
		int sizeCmn1 = Integer.parseInt(request.getParameter("sizeCmn1"));
		for(int i=0;i<sizeCmn1;i++){
			if(request.getParameter("remove"+i)!=null && request.getParameter("remove"+i).trim().equals("")){
				cdo = new CommonDataObject();
				cdo.setTableName(tableName1);
				cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
				cdo.addColValue("compania",companyId);
				cdo.addColValue("cargo",request.getParameter("id"));
				cdo.addColValue("codigo",request.getParameter("codigo"+i));
				cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
				cdo.addColValue("valor",request.getParameter("valor"+i));
				cdo.setAutoIncCol("codigo");
				cdo.setWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
				
				alCmn1.add(cdo);
			} else {
				del = "1";
			}
		}

		if(baction.equalsIgnoreCase("Agregar")){
			cdo = new CommonDataObject();
			cdo.setTableName(tableName1);
			cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);
			cdo.addColValue("compania",companyId);
			cdo.addColValue("cargo",request.getParameter("id"));
			cdo.addColValue("codigo","0");
			cdo.addColValue("descripcion","");
			cdo.addColValue("valor","");
			cdo.setAutoIncCol("codigo");
			alCmn1.add(cdo);
		}
		if (baction.equalsIgnoreCase("Guardar"))
		{
				if (alCmn1.size() == 0)
				{
					cdo = new CommonDataObject();
					cdo.setTableName(tableName1);  
					cdo.setAutoIncWhereClause("cargo='"+request.getParameter("id")+"' and compania = "+companyId);					
					alCmn1.add(cdo); 
					
				}
		}
		if(alCmn1.size()>0) htCmn.put(tableName1,alCmn1);
		
		htACu = CmnMgr.putLineNumber(htACu,alCmn1);
		if (baction.equalsIgnoreCase("Guardar")&& htCmn.size()>0){		
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.insertMultipleList(htCmn, true, true);
			ConMgr.clearAppCtx(null);
		} else {
			System.out.println("del..."+del);
			response.sendRedirect("../rhplanilla/reg_cargo.jsp?mode=edit&change=1&id="+request.getParameter("id")+"&indTab="+indTab+"&fg="+fg);
			return;
		}
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(mode,indTap)
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	
	if(mode=='edit' || mode=='add' ){
		window.location = '<%=request.getContextPath()+"/rhplanilla/reg_cargo.jsp?mode=edit&id="+id+"&fg="+fg+"&indTab="%>'+indTap;
		if(indTap=='0'){window.opener.location = '<%=request.getContextPath()%>/rhplanilla/cargos_list.jsp?fg=<%=fg%>';}
	} else{
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/cargos_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/cargos_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/cargos_list.jsp?fg=<%=fg%>';
<%
	}
%>
//window.close();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
}
</script>
</head>
<body onLoad="closeWindow('<%=mode%>',<%=indTab%>)">
</body>
</html>
<%
}//POST
%>