<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.ResourceBundle"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.awt.Color"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania"/>
<%@ include file="../common/pdf_header.jsp"%>
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
StringBuffer sbSql = new StringBuffer();
String appendFilter = request.getParameter("appendFilter");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String userName = UserDet.getUserName();
String fp = request.getParameter("fp");
String tDate = request.getParameter("tDate");
String fDate = request.getParameter("fDate");
String prov = request.getParameter("prov");
String articulo = request.getParameter("articulo");
String wh = request.getParameter("wh");
String compania = (String) session.getAttribute("_companyId");

if (wh == null) wh = "";
if (tDate == null) tDate = "";
if (fDate == null) fDate = "";
if (prov == null) prov = "";
if (articulo == null) articulo = "";
if (appendFilter == null) appendFilter = ""; 
  
sbSql.append(" select distinct al.codigo_almacen, al.descripcion  desc_almacen, prov.nombre_proveedor, ar.consignacion_sino, ar.descripcion  desc_articulo, ar.cod_flia, ar.cod_clase, ar.cod_articulo, ar.cod_flia||'-'||ar.cod_clase||'-'||ar.cod_articulo codigo_articulo, nvl((select aa.descripcion  from tbl_inv_anaqueles_x_almacen  aa where aa.compania = inv.compania and aa.codigo_almacen = inv.codigo_almacen  and aa.codigo = inv.codigo_anaquel ),'S/A') as   desc_anaquel,   nvl(inv.codigo_anaquel,-999) as codigo_anaquel ,(select aa.codigo from tbl_inv_anaqueles_x_almacen  aa where aa.compania = inv.compania  and  aa.codigo_almacen = inv.codigo_almacen  and aa.codigo = inv.codigo_anaquel ) as codigo , inv.disponible disponible ,( select cantidad_contada from tbl_inv_detalle_fisico df where df.cf1_consecutivo||'-'||df.cf1_anio = getnoconteo(inv.art_familia,inv.art_clase ,inv.cod_articulo, inv.codigo_almacen, inv.codigo_anaquel,inv.compania) and df.cod_articulo = inv.cod_articulo and df.almacen = inv.codigo_almacen  and df.anaquel = inv.codigo_anaquel ) cantidad_contada  , q.recepcion, r.dev_prov dev_proveedor,s.dev_unidad_alm dev_unidad,t.dev_almacen dev_almacen, u.v_transferencia transferencia, v.transferencia_alm transferencia_alm, w.entrega_unidad	entrega_unidad, x.entrega_paciente , y.dev_paciente dev_paciente, z.cargos_otros cargos_otros, aj.ajustes ajustes from  tbl_inv_almacen al, tbl_inv_articulo ar, tbl_inv_inventario inv, tbl_com_proveedor prov, tbl_inv_arti_prov  ap, /* AJUSTES A INVENTARIO */   (select sum(decode(ta.sign_tipo_ajuste, '+',nvl(da.cantidad_ajuste,0),-nvl(da.cantidad_ajuste,0))) ajustes,da.cod_articulo from tbl_inv_ajustes aj , tbl_inv_detalle_ajustes da , tbl_inv_tipo_ajustes ta where aj.estado = 'A' and nvl(da.check_aprov,'N') = 'S' and (da.compania = aj.compania and da.codigo_ajuste = aj.codigo_ajuste and da.numero_ajuste = aj.numero_ajuste and da.anio_ajuste = aj.anio_ajuste) and aj.codigo_ajuste = ta.codigo_ajuste ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(aj.fecha_ajuste) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(aj.fecha_ajuste) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and aj.codigo_almacen=");sbSql.append(wh);}
 sbSql.append(" and aj.compania = ");sbSql.append(compania);
 
 sbSql.append(" group by da.cod_articulo) aj,/*RECEPCIONES DE ARTICULOS*/ ( select sum( nvl(dr.cantidad,0) * nvl(dr.articulo_und,1)) recepcion, dr.cod_articulo from tbl_inv_recepcion_material  rm, tbl_inv_detalle_recepcion dr where rm.estado = 'R' and rm.fre_documento = 'NE' and ( dr.COMPANIA = rm.COMPANIA and dr.NUMERO_DOCUMENTO = rm.NUMERO_DOCUMENTO and dr.ANIO_RECEPCION = rm.ANIO_RECEPCION) ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(rm.fecha_documento) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(rm.fecha_documento) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and rm.codigo_almacen=");sbSql.append(wh);} 
sbSql.append(" and rm.compania = ");sbSql.append(compania); 
 
 sbSql.append(" group by dr.cod_articulo ) q, ");

sbSql.append(" ( /* DEVOLUCION DE PROVEEDORES */ select   sum(det.cantidad * -1) dev_prov,det.cod_articulo from tbl_inv_devolucion_prov dp , tbl_inv_detalle_proveedor det where (det.compania = dp.compania and  det.num_devolucion = dp.num_devolucion and  det.anio = dp.anio) ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(dp.fecha) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(dp.fecha) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and dp.codigo_almacen=");sbSql.append(wh);} 
sbSql.append(" and dp.compania = ");sbSql.append(compania); 

sbSql.append(" and  dp.anulado_sino = 'N'  group by  det.cod_articulo )r, ( /* DEVOLUCION DE UNIDADES */ select   sum(dd.cantidad)  dev_unidad_alm,dd.cod_articulo from tbl_inv_devolucion de, tbl_inv_detalle_devolucion dd, tbl_sec_compania co where (dd.compania = de.compania and dd.num_devolucion = de.num_devolucion and dd.anio_devolucion = de.anio_devolucion) and co.codigo = de.compania_dev ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(de.fecha_devolucion) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(de.fecha_devolucion) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and de.codigo_almacen=");sbSql.append(wh);} 
sbSql.append(" and de.compania = ");sbSql.append(compania); 

sbSql.append(" and de.tipo_transferencia in ('EA','UA') group by dd.cod_articulo  ) s, ( /* DEVOLUCION DE ALMACEN */ select   sum(dd.cantidad* -1) dev_almacen,dd.cod_articulo from tbl_inv_devolucion de, tbl_inv_detalle_devolucion dd, tbl_inv_almacen al where   (dd.compania = de.compania and dd.num_devolucion  = de.num_devolucion and dd.anio_devolucion  = de.anio_devolucion) and (de.compania = al.compania and de.codigo_almacen_q_dev = al.codigo_almacen) ");

if(!tDate.trim().equals("")){sbSql.append(" and trunc(de.fecha_devolucion) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(de.fecha_devolucion) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and de.codigo_almacen_q_dev=");sbSql.append(wh);} 
sbSql.append(" and de.compania = ");sbSql.append(compania); 


sbSql.append(" group by dd.cod_articulo )t, ( ");

/* TRANSFERENCIAS */
sbSql.append(" select sum(de.cantidad)* -1 v_transferencia ,de.cod_articulo from tbl_inv_entrega_material  em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req  sr where sr.tipo_transferencia = 'A' and (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and em.codigo_almacen=");sbSql.append(wh);} 
sbSql.append(" and em.compania = ");sbSql.append(compania); 

sbSql.append(" group by de.cod_articulo ) u, ( /* TRANSFERENCIA ENTRE ALMACENES */ select sum(de.cantidad ) transferencia_alm, de.cod_articulo	from tbl_inv_entrega_material  em, tbl_inv_detalle_entrega  de,tbl_inv_almacen al, tbl_inv_solicitud_req  sr where (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and ( em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and ( sr.compania_sol = al.compania and sr.codigo_almacen = al.codigo_almacen) and sr.tipo_transferencia = 'A' ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and sr.codigo_almacen=");sbSql.append(wh);} 
sbSql.append(" and em.compania = ");sbSql.append(compania); 

sbSql.append(" group by de.cod_articulo ) v, ( /* ENTREGAS A UNIDAD */ select    sum(de.cantidad * -1) entrega_unidad, de.cod_articulo from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_req  sr,tbl_sec_unidad_ejec ue, tbl_sec_compania  co where (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania_sol = sr.compania and em.req_solicitud_no = sr.solicitud_no and em.req_tipo_solicitud = sr.tipo_solicitud and em.req_anio = sr.anio) and ue.codigo = sr.unidad_administrativa and ue.compania = sr.compania  and co.codigo = ue.compania  and sr.tipo_transferencia in ('U','C') ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and em.codigo_almacen=");sbSql.append(wh);} 
sbSql.append(" and em.compania = ");sbSql.append(compania); 

sbSql.append(" group by de.cod_articulo ) w,");

sbSql.append("  /* ENTREGAS PACIENTES */ ( select sum(nvl(entrega_paciente,0))*-1 as entrega_paciente,cod_articulo from (select sum(de.cantidad * -1) entrega_paciente, de.cod_articulo from tbl_inv_entrega_material em, tbl_inv_detalle_entrega de, tbl_inv_solicitud_pac sp where (de.compania = em.compania and de.no_entrega = em.no_entrega and de.anio = em.anio) and (em.compania = sp.compania and em.pac_solicitud_no = sp.solicitud_no and em.pac_anio = sp.anio) ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(em.fecha_entrega) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and em.codigo_almacen=");sbSql.append(wh);} 
sbSql.append(" and em.compania = ");sbSql.append(compania); 

sbSql.append(" group by  de.cod_articulo union all select sum(decode(fdt.tipo_transaccion,'D',-fdt.cantidad,fdt.cantidad)) as v_pac,fdt.inv_articulo  from tbl_fac_detalle_transaccion fdt where fdt.compania = ");
sbSql.append(compania);

if(!tDate.trim().equals("")){sbSql.append(" and fdt.fecha_creacion >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and fdt.fecha_creacion <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and fdt.inv_almacen=");sbSql.append(wh);}  

sbSql.append(" and fdt.tipo= 'CDIR' and nvl(fdt.inv_articulo,0) <> 0 group by fdt.inv_articulo  ) group by cod_articulo )x, /* DEVOLUCIONES PACIENTES */  ( select sum(dep.cantidad)*-1 dev_paciente,dep.cod_articulo from tbl_inv_devolucion_pac dvp, tbl_inv_detalle_paciente dep where (dep.compania = dvp.compania and dep.num_devolucion = dvp.num_devolucion and dep.anio_devolucion = dvp.anio) ");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(dvp.fecha) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(dvp.fecha) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and dvp.codigo_almacen=");sbSql.append(wh);} 
sbSql.append(" and dvp.compania = ");sbSql.append(compania); 

sbSql.append(" and dvp.estado = 'R' group by  dep.cod_articulo )y, ( /* CARGOS Y DEV. OTROS CLIENTES */ select sum(decode(ft.doc_type,'D',-dt.cantidad,dt.cantidad))*-1 as cargos_otros, dt.codigo cod_articulo from tbl_fac_trxitems dt, tbl_fac_trx ft, tbl_inv_articulo ar where ft.company_id = ");
sbSql.append(compania);
sbSql.append(" and ar.cod_articulo = dt.codigo and dt.doc_id = ft.doc_id and dt.other3 ='I'");
if(!tDate.trim().equals("")){sbSql.append(" and trunc(ft.doc_date) >= to_date('");sbSql.append(tDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!fDate.trim().equals("")){sbSql.append(" and trunc(ft.doc_date) <= to_date('");sbSql.append(fDate);sbSql.append("' ,'dd/mm/yyyy')");}
if(!wh.trim().equals("")){sbSql.append(" and dt.almacen=");sbSql.append(wh);} 

  sbSql.append(" group by dt.codigo )z  where al.compania = "+compania +" and ar.estado = 'A'  and ar.consignacion_sino = 'S' ");
if(!wh.trim().equals("")){sbSql.append(" and al.codigo_almacen=");sbSql.append(wh);} 

if(!articulo.trim().equals("")){sbSql.append(" and ar.cod_articulo =");sbSql.append(articulo);}

sbSql.append("  and ar.compania = inv.compania and ar.cod_articulo = inv.cod_articulo and prov.cod_provedor = ap.cod_provedor and prov.compania = ap.compania  and inv.compania = al.compania and inv.codigo_almacen = al.codigo_almacen and ap.compania = inv.compania and ap.cod_articulo = inv.cod_articulo");

if(!prov.trim().equals("")){sbSql.append(" and ap.cod_provedor=");sbSql.append(prov);}

 sbSql.append("  and ar.cod_articulo = q.cod_articulo(+) and ar.cod_articulo = r.cod_articulo(+) and ar.cod_articulo = s.cod_articulo(+) and ar.cod_articulo = t.cod_articulo(+) and ar.cod_articulo = u.cod_articulo(+) and ar.cod_articulo = v.cod_articulo(+) and ar.cod_articulo = w.cod_articulo(+) and ar.cod_articulo = x.cod_articulo(+) and ar.cod_articulo = y.cod_articulo(+) and ar.cod_articulo = z.cod_articulo(+) and ar.cod_articulo = aj.cod_articulo(+) order by  1,11 asc ,3,ar.cod_articulo ");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET"))
{
	String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = true;
	float leftRightMargin = 9.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "LISTADO DE PRODUCTOS ACTIVOS A CONSIGNACION ";
	String subtitle = "DESDE     "+tDate+"     HASTA    "+fDate;
    String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	String fontFamily = "HELVETICA";//"TIMES";//"COURIER";//
	int fontSize = 9;
	float cHeight = 11.0f;

	PdfCreator pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);

	Vector dHeader = new Vector();
		dHeader.addElement(".08");
		dHeader.addElement(".27");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");
		dHeader.addElement(".05");

	//table header
	pc.setNoColumnFixWidth(dHeader);
	pc.createTable();
		//first row
		pdfHeader(pc, _comp, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());

		//second row

		pc.setFont(7,0);
		pc.addBorderCols("CODIGO",1);
		pc.addBorderCols("NOMBRE ARTICULO",1);
		pc.addBorderCols("CONTEO FISICO",1);
		pc.addBorderCols("RECEPCIONES",1);
		pc.addBorderCols("TRANSF. A ALM",1);
		pc.addBorderCols("DEV. UNDS,CIA Y ALM",1);

		pc.addBorderCols("DEVOL. A PACTES",1);
		pc.addBorderCols("CARGOS DEV. OTROS",1);
		pc.addBorderCols("ENTREGA PACTES",1);
		pc.addBorderCols("ENTREGA. UNID ADM",1);
		pc.addBorderCols("TRANSF. DESDE ALM",1);
		pc.addBorderCols("DEVOL.  DEL ALM",1);

		pc.addBorderCols("DEVOL.  PROVEE",1);
		pc.addBorderCols("AJUSTES",1);
		pc.addBorderCols("CANTIDAD DISP",1);
	pc.setTableHeader(2);//create de table header (2 rows) and add header to the table

	//table body
	String groupBy = "",groupByWh="",subGroupBy="";
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		
		if (!groupByWh.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
		{
			if(i!=0)
			{
				pc.addBorderCols(" ",1, 15, 0.0f, 0.5f, 0.0f, 0.0f,cHeight); 
			}
			pc.setFont(7, 1);
 			pc.addCols(" "+cdo.getColValue("codigo_almacen")+"      "+cdo.getColValue("desc_almacen"),0,dHeader.size());
			
			
 		}
		if (!groupBy.equalsIgnoreCase(cdo.getColValue("codigo_anaquel"))|| !groupByWh.equalsIgnoreCase(cdo.getColValue("codigo_almacen")))
		{
				 
				if(i!=0)
			{
				pc.addBorderCols(" ",1, 15, 0.0f, 0.5f, 0.0f, 0.0f,cHeight); 
			}
  
				pc.setFont(7, 1);
 				pc.addBorderCols("ANAQUEL: "+cdo.getColValue("desc_anaquel"),0,dHeader.size());
 		}
		
		if (!subGroupBy.equalsIgnoreCase(cdo.getColValue("nombre_proveedor")) ||(!groupBy.equalsIgnoreCase(cdo.getColValue("codigo_anaquel"))|| !groupByWh.equalsIgnoreCase(cdo.getColValue("codigo_almacen"))))
		{
			if(i!=0)
			{
				pc.addBorderCols(" ",1, 15, 0.0f, 0.5f, 0.0f, 0.0f,cHeight); 
			}
			
			pc.setFont(7, 1);
 			//pc.addCols(" "+,0,dHeader.size());
			 
			pc.addBorderCols(" "+cdo.getColValue("nombre_proveedor"),0, 15, 0.5f, 0.0f, 0.0f, 0.0f,cHeight); 
  		}

		

		
			pc.setFont(7, 0);
 
 			pc.addBorderCols(" "+cdo.getColValue("codigo_articulo")   ,0, 1, 0.0f, 0.0f, 0.5f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("desc_articulo")     ,0, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("cantidad_contada")  ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("recepcion")         ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("transferencia")     ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("dev_unidad")        ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("dev_paciente")     ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("cargos_otros")      ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("entrega_paciente")  ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("entrega_unidad")    ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("transferencia_alm") ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("dev_almacen")       ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("dev_proveedor")     ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			pc.addBorderCols(" "+cdo.getColValue("ajustes")           ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			if(cdo.getColValue("disponible") != null && !cdo.getColValue("disponible").trim().equals("0"))
			pc.addBorderCols(" "+cdo.getColValue("disponible")        ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
			else pc.addBorderCols(" "                                 ,1, 1, 0.0f, 0.0f, 0.0f, 0.5f);
		
		groupByWh  = cdo.getColValue("codigo_almacen");
		subGroupBy = cdo.getColValue("nombre_proveedor");
		groupBy    = cdo.getColValue("codigo_anaquel");
		if ((i % 50 == 0) || ((i + 1) == al.size())) pc.flushTableBody(true);
	}
	if (al.size() == 0) pc.addCols("No existen registros",1,dHeader.size());
	else 
	{
 		pc.addBorderCols(" ",1, 15, 0.0f, 0.5f, 0.0f, 0.0f,cHeight);  
	}
	
	pc.addTable();
	pc.close();
	response.sendRedirect(redirectFile);
}//GET
%>