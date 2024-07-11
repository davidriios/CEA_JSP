<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
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

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList alTPR = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String anio = request.getParameter("anio");
String mes = request.getParameter("mes");
String quincena = request.getParameter("quincena");
String periodo = request.getParameter("periodo");
String cierre = request.getParameter("cierre");
String grupo = request.getParameter("unidad");
String finicio = request.getParameter("finicio");
String ffinal = request.getParameter("ffinal");
String emp_id = request.getParameter("emp_id");
String appendFilter = request.getParameter("appendFilter");
double totExtra=0.00, totSal=0.00, totVac=0.00, totDec=0.00,totInc=0.00, totBon=0.00;
double totOing=0.00, totGrep=0.00, totAus=0.00, totTar=0.00,totOegr=0.00, totOtr=0.00;
double totPant=0.00, totInd=0.00, totPre=0.00, totImp=0.00,totSsoc=0.00, totSedu=0.00, totSnet=0.00,totProd=0.00;
StringBuffer sbSql = new StringBuffer();

boolean viewMode = false;
int lineNo = 0;
//System.out.println("grp="+grupo);
CommonDataObject cdoDM = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="emp_otros_pagos";
if(grupo==null) grupo="";
if(finicio==null) finicio="";
if(ffinal==null) ffinal="";
if(mode.equals("view")) viewMode = true;
if(emp_id==null) emp_id="";
if(appendFilter==null) appendFilter="";
if(anio==null) anio= "";

if (request.getMethod().equalsIgnoreCase("GET"))
{

  if (!emp_id.trim().equals("") && !ffinal.trim().equals("")){
  	/*
  		if(anio.trim().equals(""))	anio=	ffinal.substring(6,10);
		sbSql = new StringBuffer();
		sbSql.append("call sp_pla_cal_acumulado_001(");
		sbSql.append(anio);
		sbSql.append(",");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(",");
		sbSql.append(emp_id);
		sbSql.append(",'");
		sbSql.append(IBIZEscapeChars.forSingleQuots(ffinal).trim());
		sbSql.append("',");
		sbSql.append(periodo);
		sbSql.append(")");
		SQLMgr.execute(sbSql.toString());
		if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());
  	*/

	if (!ffinal.trim().equals("")) appendFilter += " and trunc(pe.fecha_pago) <= to_date('"+ffinal+"','dd/mm/yyyy') ";
	if (!finicio.trim().equals(""))appendFilter += " and trunc(pe.fecha_pago) >= to_date('"+finicio+"','dd/mm/yyyy')";
	sbSql = new StringBuffer();
	sbSql.append("select  pe.anio,pe.fecha_pago,pe.periodo, pd.num_planilla, pd.emp_id, pd.cod_planilla,pl.cod_concepto, to_char(to_date(pe.fecha_pago,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') descripcion, pd.num_empleado,nvl(decode(pd.cod_pla_aj,'3',0,'2',0,6,0,decode(pd.cod_planilla,'1',pd.sal_ausencia,'7',pd.sal_ausencia,0)),0) salario, nvl(pd.extra,0) extra,nvl(decode(pd.cod_planilla,'2',pd.sal_ausencia,decode(pd.cod_pla_aj,'2',pd.sal_ausencia,0)),0) decimo,nvl(decode(pd.cod_pla_aj,'3',pd.sal_ausencia,decode(pd.cod_planilla,'3',pd.sal_ausencia,0)),0) vacacion, nvl(decode(pd.cod_planilla,'5',pd.sal_ausencia,'7',pd.bonificacion,1,pd.bonificacion,0),0) bonificacion, nvl(decode(pd.cod_pla_aj,'6',pd.sal_ausencia,decode(pd.cod_planilla,'6',pd.sal_ausencia,0)),0) incentivo, nvl(pd.otros_ing,0) otros_ingresos, nvl(pd.gasto_rep,0) gasto_rep, nvl(pd.ausencia,0) ausencias, nvl(pd.tardanza,0) tardanzas, nvl(pd.otros_egr,0)+nvl(pd.otras_ded,0) otros_egresos, 0 otros, nvl(pd.seg_social,0) seg_social, nvl(pd.seg_educativo,0) seg_educativo, nvl(pd.imp_renta,0) imp_renta, 0 prima_antiguedad, 0 indemnizacion, 0 preaviso, nvl(pd.sal_neto,0) sal_neto, nvl(nvl(pd.sal_ausencia,0)+nvl(pd.ausencia,0)+nvl(pd.tardanza,0),pd.sal_bruto) sal_bruto, nvl(pd.otras_ded,0) otras_ded, nvl(pe.planilla_mensual,'N') planilla_mensual, decode(pe.periodo_mes,1,'PRIMERA','SEGUNDA') quincena,nvl(pd.prima_produccion,0) primaProd,'A' descType  from  tbl_pla_pago_empleado pd, tbl_pla_planilla_encabezado pe, tbl_pla_planilla pl where pd.cod_compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and pd.emp_id = ");
	sbSql.append(emp_id);
	sbSql.append(appendFilter);
	sbSql.append(" and pe.cod_planilla = pd.cod_planilla and pe.num_planilla = pd.num_planilla and pl.cod_planilla = pe.cod_planilla and pl.compania = pe.cod_compania and pe.anio = pd.anio and pe.cod_compania = pd.cod_compania ");

sbSql.append(" union all ");

 sbSql.append(" select   pe.anio,pe.fecha_pago,pe.periodo,pd.num_planilla,pd.emp_id, pd.cod_planilla, pl.cod_concepto,to_char(to_date(pe.fecha_pago,'dd/mm/yyyy'),'FMMONTH','NLS_DATE_LANGUAGE=SPANISH') descripcion, pd.num_empleado,nvl(pd.salario,0)salario,nvl(pd.extra,0)extra,nvl(pd.xiii_mes,0)decimo,nvl(pd.vacacion,0)vacacion,nvl(pd.bonificacion,0)bonificacion, 0 incentivo, nvl(pd.otros_ing,0) otros_ingresos, nvl(pd.gasto_rep,0)gasto_rep,nvl(pd.ausencia,0)ausencia, nvl(pd.tardanza,0)tardanzas,nvl(pd.otros_egr,0)otros_egresos, 0 otros,nvl(pd.seg_social,0) seg_social, nvl(pd.seg_educativo,0) seg_educativo, nvl(pd.imp_renta,0) imp_renta, nvl(pd.prima_antiguedad,0)prima_antiguedad,  nvl(pd.indemnizacion,0) indemnizacion, nvl(pd.preaviso,0) preaviso, nvl(pd.sal_neto,0) sal_neto,nvl(nvl(pd.salario,0) + nvl(pd.extra,0) + nvl(pd.prima_antiguedad,0) + nvl(pd.preaviso,0) + nvl(pd.bonificacion,0) + nvl(pd.gasto_rep,0) + nvl(pd.indemnizacion,0) + nvl(pd.xiii_mes,0) + nvl(pd.vacacion,0) - nvl(pd.otros_egr,0),0) sal_bruto, nvl(pd.otras_ded,0) otras_ded,nvl(pe.planilla_mensual,'N') planilla_mensual, decode(pe.periodo_mes,1,'PRIMERA','SEGUNDA') quincena,nvl(pd.prima_produccion,0) primaProd,'B' descType from tbl_pla_pago_liquidacion pd,tbl_pla_planilla pl,tbl_pla_planilla_encabezado pe where pd.cod_compania =  ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and pd.emp_id = ");
	sbSql.append(emp_id);
	sbSql.append(appendFilter);
	sbSql.append(" and pe.cod_planilla = pd.cod_planilla and pe.num_planilla = pd.num_planilla and pe.anio = pd.anio and pe.cod_compania = pd.cod_compania  and pl.cod_planilla = pe.cod_planilla and pl.compania = pe.cod_compania order by 1 desc,2 desc,3 desc, 4 desc");
		alTPR = SQLMgr.getDataList(sbSql.toString());
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){}
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
<%=fb.hidden("anio",anio)%>
<%=fb.hidden("mes",mes)%>
<%=fb.hidden("quincena",quincena)%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
		  <td align="center" width="4%"><cellbytelabel>A&ntilde;o</cellbytelabel></td>
          <td align="center" width="4%"><cellbytelabel>Periodo</cellbytelabel></td>
          <td align="center" width="8%"><cellbytelabel>Mes</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Quincena</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Salario</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Horas Extra</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Vacaciones</cellbytelabel></td>
           <td align="center" width="10%"><cellbytelabel>XIII Mes</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Incentivo</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Bonificacion</cellbytelabel></td>
		  <td align="center" width="10%"><cellbytelabel>P. Prod</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>Otros Ingresos</cellbytelabel></td>
           <td align="center" width="10%"><cellbytelabel>Gasto Rep</cellbytelabel>.</td>
           <td align="center" width="10%"><cellbytelabel>Ausencias</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Tardanzas</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>O. Egresos/O. Ded</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>Otros</cellbytelabel></td>
           <td align="center" width="10%"><cellbytelabel>Prima Ant</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>Indemnizacion</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Preaviso</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Imp.Renta</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Seg.Social</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Seg.Educ</cellbytelabel>.</td>
          <td align="center" width="10%"><cellbytelabel>SalarioNeto</cellbytelabel></td>

        </tr>
        <%
				for (int i=0; i<alTPR.size(); i++){
					key = alTPR.get(i).toString();
          CommonDataObject cdo = (CommonDataObject) alTPR.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;

		  totSal+=Double.parseDouble(cdo.getColValue("salario")) ;
		  totExtra+=Double.parseDouble(cdo.getColValue("extra")) ;
		  totVac+=Double.parseDouble(cdo.getColValue("vacacion")) ;
		  totDec+=Double.parseDouble(cdo.getColValue("decimo")) ;
		  totInc+=Double.parseDouble(cdo.getColValue("incentivo")) ;
		  totBon+=Double.parseDouble(cdo.getColValue("bonificacion")) ;
		  totOing+=Double.parseDouble(cdo.getColValue("otros_ingresos")) ;
		  totGrep+=Double.parseDouble(cdo.getColValue("gasto_rep")) ;
		  totAus+=Double.parseDouble(cdo.getColValue("ausencias")) ;
		  totTar+=Double.parseDouble(cdo.getColValue("tardanzas")) ;
		  totOegr+=Double.parseDouble(cdo.getColValue("otros_egresos")) ;
		  totOtr+=Double.parseDouble(cdo.getColValue("otros")) ;

		  totPant+=Double.parseDouble(cdo.getColValue("prima_antiguedad")) ;
		  totInd+=Double.parseDouble(cdo.getColValue("indemnizacion")) ;
		  totPre+=Double.parseDouble(cdo.getColValue("preaviso")) ;
		  totImp+=Double.parseDouble(cdo.getColValue("imp_renta")) ;
		  totSsoc+=Double.parseDouble(cdo.getColValue("seg_social")) ;
		  totSedu+=Double.parseDouble(cdo.getColValue("seg_educativo")) ;
		  totSnet+=Double.parseDouble(cdo.getColValue("sal_neto")) ;
		  totProd+=Double.parseDouble(cdo.getColValue("primaProd")) ;
		%>
        <%=fb.hidden("emp_id"+i, cdo.getColValue("emp_id"))%>
        <%=fb.hidden("ue_codigo"+i, cdo.getColValue("ue_codigo"))%>
        <%=fb.hidden("anioPago"+i, anio)%>
        <%=fb.hidden("dsp_cedula"+i, cdo.getColValue("dsp_cedula"))%>
        <%=fb.hidden("num_empleado"+i, cdo.getColValue("num_empleado"))%>
        <%=fb.hidden("nombre_empleado"+i, cdo.getColValue("nombre_empleado"))%>
        <%=fb.hidden("unidad_organi"+i, cdo.getColValue("unidad_organi"))%>
        <%=fb.hidden("fecha_ingreso"+i, cdo.getColValue("fecha_ingreso"))%>
		<%=fb.hidden("estado"+i, cdo.getColValue("estado"))%>
		<%=fb.hidden("inicio"+i, finicio)%>
		<%=fb.hidden("final"+i, ffinal)%>
		<%=fb.hidden("grupo"+i, grupo)%>
		<%=fb.hidden("quincenaPago"+i, quincena)%>

        <tr class="<%=color%>" align="center">
		 	<td align="left"><%=cdo.getColValue("anio")%></td>
          	<td align="center"><%=cdo.getColValue("periodo")%></td>
         	<td align="left"><%=cdo.getColValue("descripcion")%></td>
         	<td align="left"><%=cdo.getColValue("quincena")%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("salario"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("extra"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("vacacion"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("decimo"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("incentivo"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("bonificacion"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("primaProd"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("otros_ingresos"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("gasto_rep"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("ausencias"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("tardanzas"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("otros_egresos"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("otros"))%></td>

             <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("prima_antiguedad"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("indemnizacion"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("preaviso"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("imp_renta"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("seg_social"))%></td>
            <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("seg_educativo"))%></td>
			<td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("sal_neto"))%></td>

            </tr>

        <%}%>
        <tr class="TextHeader02" align="center">
          <td align="center" colspan="4">Total de registros:&nbsp;<font class="WhiteTextBold"><%=alTPR.size()%></font></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totSal)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totExtra)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totVac)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totDec)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totInc)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totBon)%></td>
		  <td align="right"><%=CmnMgr.getFormattedDecimal(totProd)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totOing)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totGrep)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totAus)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totTar)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totOegr)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totOtr)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totPant)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totInd)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totPre)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totImp)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totSsoc)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totSedu)%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(totSnet)%></td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.hidden("keySize",""+alTPR.size())%>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET
%>