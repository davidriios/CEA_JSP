<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdoSI = new CommonDataObject();
StringBuffer sbSql  = new StringBuffer();

String change = request.getParameter("change");
String key = "";
String sql = "", appendFilter = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String anio = request.getParameter("anio");
String anioSaldoIni = request.getParameter("anioSaldoIni");
String mes = request.getParameter("mes");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
String cta1 = request.getParameter("cta1");
String cta2 = request.getParameter("cta2");
String cta3 = request.getParameter("cta3");
String cta4 = request.getParameter("cta4");
String cta5 = request.getParameter("cta5");
String cta6 = request.getParameter("cta6");
String num_cta = request.getParameter("num_cta");
String tipoReg = request.getParameter("tipoReg");
String resumen = request.getParameter("resumen");
String tipoComprob = request.getParameter("tipoComprob");

boolean viewMode = false;
int lineNo = 0;

CommonDataObject cdoT = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="cat_ctas";
if(fg==null) fg="";
if(mode.equals("view")) viewMode = true;
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if(anio==null) anio = "";
if(anioSaldoIni==null) anioSaldoIni = "";
if(mes==null) mes = "";
if(tipoReg==null) tipoReg = "";
if(resumen==null) resumen = "";
if(tipoComprob==null) tipoComprob = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!fechaini.equals("") && !fechafin.equals(""))
	{ appendFilter += " /*------ RANGO FECHA */ and to_date(to_char(fecha_comp, 'dd/mm/yyyy'), 'dd/mm/yyyy') between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')";
		//sql = "select nvl(sum(decode(c.tipo_mov, 'DB', valor,'CR',-1*valor)),0) saldo_inicial from tbl_con_encab_comprob a, tbl_con_clases_comprob b, tbl_con_detalle_comprob c, vw_con_catalogo_gral d where a.status = 'AP' and a.clase_comprob = b.codigo_comprob and b.tipo='C' and a.ea_ano = c.ano and a.consecutivo = c.consecutivo and a.compania = c.compania and a.tipo = c.tipo and c.cta1 = d.cta1 and c.cta2 = d.cta2 and c.cta3 = d.cta3 and c.cta4 = d.cta4 and c.cta5 = d.cta5 and c.cta6 = d.cta6 and c.compania = d.compania and a.compania = " + (String) session.getAttribute("_companyId") + " and d.num_cuenta like '"+num_cta+"%'"+ appendFilter+"";
		sql = "select nvl(monto_i, 0) saldo_inicial, nvl(getSiComprobCta (pc_compania,null,null,'"+fechaini+"','"+num_cta+"','"+tipoReg+"'),0) as si_comp from tbl_con_mov_mensual_cta where pc_compania = " + (String) session.getAttribute("_companyId") + " and ea_ano = to_char(to_date('" + fechaini+ "','dd/mm/yyyy'),'YYYY') and mes =to_char(to_date('" + fechaini+ "','dd/mm/yyyy'),'MM') and cat_cta1 = '"+cta1+"' and cat_cta2 = '"+cta2+"' and cat_cta3 = '"+cta3+"' and cat_cta4 = '"+cta4+"' and cat_cta5 = '"+cta5+"' and cat_cta6 = '" + cta6 + "'";
	    //cdoSI.addColValue("saldo_inicial","0");
		cdoSI = SQLMgr.getData(sql);
	}
	if (!anio.equals("") && !mes.equals(""))
	{appendFilter += " /*------ AÑO - MES */ and a.ea_ano = "+anio+" and a.mes = "+mes;
 	sql = "select nvl(monto_i, 0) saldo_inicial, nvl(getSiComprobCta (pc_compania,'"+anio+"','"+mes+"',null,'"+num_cta+"','"+tipoReg+"'),0) as si_comp from tbl_con_mov_mensual_cta where pc_compania = " + (String) session.getAttribute("_companyId") + " and ea_ano = " + anio+ " and mes ="+mes+" and cat_cta1 = '"+cta1+"' and cat_cta2 = '"+cta2+"' and cat_cta3 = '"+cta3+"' and cat_cta4 = '"+cta4+"' and cat_cta5 = '"+cta5+"' and cat_cta6 = '" + cta6 + "'";
		cdoSI = SQLMgr.getData(sql);
	}
	if(cdoSI == null)
	{
	 cdoSI =new CommonDataObject();
	 cdoSI.addColValue("saldo_inicial","0");
	 cdoSI.addColValue("si_comp","0");
	 
	}
	if(!tipoReg.equals(""))appendFilter += " and nvl(a.creado_por,'X')='"+tipoReg+"'";
	if(!tipoComprob.equals(""))appendFilter += " and a.clase_comprob="+tipoComprob;

sbSql.append("select ");
	if(resumen.trim().equals("S"))
	{
		sbSql.append(" c.tipo_mov,a.tipo,'' as consecutivo,'' as ea_ano,a.reg_type,'' as fecha_comp,c.num_cuenta,d.descripcion||decode(a.tipo,1,' ',2,'      *** ANULADO ' ) nombre_cta,b.nombre_corto as comprob_desc,a.estado,  c.cta1, c.cta2, c.cta3, c.cta4, c.cta5, c.cta6, sum(decode(c.tipo_mov, 'DB', valor)) debito, sum(decode(c.tipo_mov, 'CR', valor)) credito");
	
	}
	else
	{
		sbSql.append(" c.tipo_mov,a.tipo,a.consecutivo,a.ea_ano,a.reg_type,to_char (a.fecha_comp, 'dd/mm/yyyy') as fecha_comp,c.num_cuenta, d.descripcion||decode(a.tipo,1,' ',2,'      *** ANULADO ' ) nombre_cta,b.nombre_corto as comprob_desc,a.estado,  c.cta1, c.cta2, c.cta3, c.cta4, c.cta5, c.cta6, decode(c.tipo_mov, 'DB', valor) debito, decode(c.tipo_mov, 'CR', valor) credito ");
	}
	sbSql.append("  from tbl_con_encab_comprob a, tbl_con_clases_comprob b, tbl_con_detalle_comprob c, vw_con_catalogo_gral d where a.status = 'AP' and a.estado ='A' and a.clase_comprob = b.codigo_comprob and b.tipo='C' and a.ea_ano = c.ano and a.consecutivo = c.consecutivo and a.compania = c.compania and a.tipo = c.tipo and a.reg_type=c.reg_type and c.cta1 = d.cta1 and c.cta2 = d.cta2 and c.cta3 = d.cta3 and c.cta4 = d.cta4 and c.cta5 = d.cta5 and c.cta6 = d.cta6 and c.compania = d.compania and a.compania = " + (String) session.getAttribute("_companyId") + " and d.num_cuenta like '");
	sbSql.append(num_cta);
	sbSql.append("%'");
	sbSql.append(appendFilter);
	if(resumen.trim().equals("S")){sbSql.append(" group by  c.tipo_mov,a.tipo,a.reg_type,c.num_cuenta,d.descripcion||decode(a.tipo,1,' ',2,'      *** ANULADO ' ),b.nombre_corto ,a.estado,  c.cta1, c.cta2, c.cta3, c.cta4, c.cta5, c.cta6 ");}
	if(resumen.trim().equals("S")){sbSql.append(" order by b.nombre_corto ");}
	else sbSql.append(" order by a.ea_ano, a.mes, a.consecutivo,a.tipo");
		al = SQLMgr.getDataList(sbSql.toString());
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){}
function ver(no,anio,tipo,regType){<%if(fg.trim().equals("")){%>if(anio!='')abrir_ventana('../contabilidad/reg_comp_diario.jsp?mode=view&fg=CD&anio='+anio+'&no='+no+'&tipo='+tipo+'&regType='+regType);<%}%>}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="4%">No.</td>
          <td align="center" width="8%">Fecha</td>
          <td align="center" width="45%">Descripci&oacute;n</td>
		  <td align="center" width="13%">Comprob.</td>
          <td align="center" width="10%">D&eacute;bito</td>
          <td align="center" width="10%">Cr&eacute;dito</td>
          <td align="center" width="10%">Saldo</td>
        </tr>
        <tr class="TextHeader01" align="center">
          <td align="right" colspan="4">Saldo Inicial</td>
          <td align="right">&nbsp;</td>
          <td align="right">&nbsp;</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(((!tipoReg.equals(""))?cdoSI.getColValue("si_comp"):cdoSI.getColValue("saldo_inicial")))%></td>
        </tr>
        <%
				double saldo = Double.parseDouble(((!tipoReg.equals(""))?cdoSI.getColValue("si_comp"):cdoSI.getColValue("saldo_inicial")));
				double debito=0.00,credito=0.00,total=0.00;
				for (int i=0; i<al.size(); i++){
          CommonDataObject cdo = (CommonDataObject) al.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
		 
		  
					if(cdo.getColValue("tipo_mov") != null && cdo.getColValue("tipo_mov").equals("DB")){ saldo += Double.parseDouble(cdo.getColValue("debito")); debito += Double.parseDouble(cdo.getColValue("debito"));}
					else {saldo -= Double.parseDouble(cdo.getColValue("credito"));credito += Double.parseDouble(cdo.getColValue("credito"));}
		 boolean isInactive = cdo.getColValue("tipo")!=null && cdo.getColValue("tipo").equals("2");		
          %>
        <tr style="cursor:pointer" title="<%=isInactive?"ANULADO":""%>" class="<%=color%>" align="center" onClick="javascript:ver('<%=cdo.getColValue("consecutivo")%>','<%=cdo.getColValue("ea_ano")%>','<%=cdo.getColValue("tipo")%>','<%=cdo.getColValue("reg_type")%>')">
          <td align="center"><%=cdo.getColValue("consecutivo")%></td>
          <td align="center"><%=cdo.getColValue("fecha_comp")%></td>
          <td align="left"><%=cdo.getColValue("num_cuenta")%>&nbsp;&nbsp;-&nbsp;&nbsp;<%=cdo.getColValue("nombre_cta")%></td>
		  <td align="left"><%=cdo.getColValue("comprob_desc")%></td>
          <td align="right"><%=(!cdo.getColValue("debito").equals("")?CmnMgr.getFormattedDecimal(cdo.getColValue("debito")):"")%></td>
          <td align="right"><%=(!cdo.getColValue("credito").equals("")?CmnMgr.getFormattedDecimal(cdo.getColValue("credito")):"")%></td>
          <td align="right">
					<font class="<%=(saldo<0?"RedTextBold":color)%>"><%=CmnMgr.getFormattedDecimal(saldo)%></font>
          </td>
        </tr>
        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="right" colspan="4">Total</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(debito)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(credito)%></td>
          <td align="right"><font class="<%=(saldo<0?"RedTextBold":"")%>"><%=CmnMgr.getFormattedDecimal(saldo)%></font></td>
        </tr>
		<tr class="TextHeader02" align="center">
          <td align="right" colspan="4"> </td> 
          <td align="right" colspan="2"><%=CmnMgr.getFormattedDecimal(debito-credito)%></td>
          <td align="right">&nbsp;</td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
/*else
{
	String dl = "", sqlItem = "";
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String clearHT = request.getParameter("clearHT");
	if(clearHT==null) clearHT = "N";
	if(clearHT.equals("S")) keySize = 0;
	alTPR.clear();
	emp.clear();
	lineNo = 0;
	for (int i=0; i<keySize; i++){
		CommonDataObject cdo = new CommonDataObject();
		if(request.getParameter("chk"+i)!=null){
			cdo.addColValue("emp_id", request.getParameter("emp_id"+i));
			cdo.addColValue("num_empleado", request.getParameter("num_empleado"+i));
			cdo.addColValue("ced_provincia", request.getParameter("ced_provincia"+i));
			cdo.addColValue("ced_sigla", request.getParameter("ced_sigla"+i));
			cdo.addColValue("ced_tomo", request.getParameter("ced_tomo"+i));
			cdo.addColValue("ced_asiento", request.getParameter("ced_asiento"+i));
			cdo.addColValue("tipo_accion", request.getParameter("tipo_accion"+i));
			cdo.addColValue("sub_t_accion", request.getParameter("sub_t_accion"+i));
			cdo.addColValue("fecha_doc", request.getParameter("fecha_doc"+i));
			cdo.addColValue("codigo_estructura", request.getParameter("codigo_estructura"+i));
			cdo.addColValue("usuario_creacion", (String) session.getAttribute("_userName"));
			cdo.addColValue("compania", (String) session.getAttribute("_companyId"));
			if (request.getParameter("baction").equalsIgnoreCase("Aplicar Accion de Ingreso")) cdo.addColValue("accion", "aplicar");
			else if (request.getParameter("baction").equalsIgnoreCase("Anular Accion de Ingreso")) cdo.addColValue("accion", "anular");
			alTPR.add(cdo);
		}
	}

	if (request.getParameter("baction").equalsIgnoreCase("Aplicar Accion de Ingreso") || request.getParameter("baction").equalsIgnoreCase("Anular Accion de Ingreso")){
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		AEmpMgr.aplica_anulaAccIngreso(alTPR);
		ConMgr.clearAppCtx(null);
	}

%>
<html>
<head>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow(){
parent.document.form1.errCode.value='<%=AEmpMgr.getErrCode()%>';
parent.document.form1.errMsg.value='<%=AEmpMgr.getErrMsg()%>';
parent.document.form1.submit();
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
*/
%>