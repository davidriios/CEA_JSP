<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.StringTokenizer" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.FTP"%>
<%@ page import="issi.admin.TextFile"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="java.util.ResourceBundle"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="FPMgr" scope="page" class="issi.admin.FileMgr"/>
<%
/**
================================================================================

================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

StringBuffer sbSql= new StringBuffer();
StringBuffer sbH= new StringBuffer();
StringBuffer sbP= new StringBuffer();
StringBuffer sbC= new StringBuffer();
StringBuffer sbF= new StringBuffer();
StringBuffer sbText= new StringBuffer();
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String noSecuencia=request.getParameter("noSecuencia");
String fg=request.getParameter("fg");
String empAxa =request.getParameter("aseg");
ArrayList al = new ArrayList();
FTP ftp = new FTP();
boolean useFtp = false;
if(noSecuencia==null) noSecuencia="";
if(empAxa==null) empAxa="";

sbSql.append("select doc_code, doc_path, remote_host, remote_port, remote_user, remote_password");
sbSql.append(", nvl(remote_pasv_mode,'N') as remote_pasv_mode from tbl_sec_doc_path");
sbSql.append(" where upper(doc_code) = 'AXA837'");
CommonDataObject cdFTP = SQLMgr.getData(sbSql.toString());
String path = "", host = "", port = "", user = "", pass = "", pasvMode = "";
if (cdFTP!=null)
{
	path = cdFTP.getColValue("doc_path");
	host = cdFTP.getColValue("remote_host");
	port = cdFTP.getColValue("remote_port");
	user = cdFTP.getColValue("remote_user");
	pass = cdFTP.getColValue("remote_password");
	pasvMode = cdFTP.getColValue("remote_pasv_mode");
}
String newLine = "\r";
/*
cdatemmyydd				=Date of interchange  "YYMMDD" ejemplo 060323
ctimehh24mi				=Time of interchange  "HHMM" ejemplo 0934
secuencia		=Assigned by sender, Incremented by one for each Interchange ejemplo 100000001
cdateyyyymmdd	=System Date in "CCYYMMDD" format ejemplo 20060323
*/

sbSql= new StringBuffer();
sbSql.append("select to_char(sysdate, 'YYMMDD') cdatemmyydd, to_char(sysdate, 'HH24MI') ctimehh24mi, lpad (to_char(sysdate, 'yymmdd')||");
sbSql.append(id);
sbSql.append(", 9, 0) secuencia, to_char(sysdate, 'yyyymmdd') cdateyyyymmdd from dual");
cdo = SQLMgr.getData(sbSql.toString());
if(!noSecuencia.equals("")) cdo.addColValue("secuencia", noSecuencia);
CommonDataObject cdoH = new CommonDataObject();
sbSql = new StringBuffer();
sbSql.append("select id, body from tbl_fac_axa837_body order by id");
al = SQLMgr.getDataList(sbSql.toString());
for(int i=0;i<al.size();i++){
	CommonDataObject cd = (CommonDataObject) al.get(i);
	if(cd.getColValue("id").equals("1")) sbH.append(cd.getColValue("body"));
	else if(cd.getColValue("id").equals("2")) sbP.append(cd.getColValue("body"));
	else if(cd.getColValue("id").equals("3")) sbC.append(cd.getColValue("body"));
	else if(cd.getColValue("id").equals("5")) sbF.append(cd.getColValue("body"));
//	System.out.println("sbH..."+cd.getColValue("id"));
//	System.out.println("sbH..."+cd.getColValue("body"));
}
//System.out.println("al.size()="+al.size());
sbText.append(sbH.toString().replaceAll("@@cdatemmyydd", cdo.getColValue("cdatemmyydd")).replaceAll("@@ctimehh24mi", cdo.getColValue("ctimehh24mi")).replaceAll("@@secuencia", cdo.getColValue("secuencia")).replaceAll("@@cdateyyyymmdd", cdo.getColValue("cdateyyyymmdd")));
//System.out.println("file...\n"+sbText.toString());
sbText.append(newLine);

sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(-1,'COD_EMP_AXA'),'-') as empr_axa,nvl(get_sec_comp_param(-1,'USA_DET_CARGO_AXA'),'N')as det_cargos from dual");
CommonDataObject p = SQLMgr.getData(sbSql.toString());
if (p != null && p.getColValue("empr_axa").equals("-")) throw new Exception("El parámetro de la empresa AXA [COD_EMP_AXA] no está definido!");

sbSql = new StringBuffer();
sbSql.append("select icd_version from tbl_adm_empresa where codigo = ");
sbSql.append(empAxa);
CommonDataObject empr = SQLMgr.getData(sbSql.toString());
if (empr == null) throw new Exception("La empresa AXA ("+p.getColValue("empr_axa")+") definida en el parámetro [COD_EMP_AXA] no existe!");

sbSql = new StringBuffer();
sbSql.append("select to_char(f.admi_fecha_nacimiento, 'yyyymmdd') dob, f.admi_codigo_paciente, f.admi_secuencia, f.fecha, f.cod_empresa, f.codigo, f.grang_total totalfac, p.primer_nombre first_name, nvl (p.primer_apellido, p.apellido_de_casada) last_name, nvl (substr (p.residencia_direccion, 1, 25), 'S/D') residencia_direccion, /*residencia_pais,*/ nvl (p.zona_postal, 's/z') zona_postal, nvl (p.apartado_postal, 's/a') apartado_postal, decode (p.sexo, 'M', 'M', 'F', 'F', 'U') sexo, nvl (p.f_nac, p.fecha_nacimiento) fechareal, decode (a.categoria, 1, 1, 2, 3) categoria, a.centro_servicio, a.tipo_admision, decode(substr(p.apartado_postal, instr(p.apartado_postal, '-')+1, length(p.apartado_postal)), '00', 'S', 'N') dueno, nvl(x.num_aprobacion, '') autorizacion, f.codigo facno, trim(to_char((select sum(decode(tipo_transaccion, 'D', -cantidad, cantidad)*monto) from tbl_fac_detalle_transaccion dt where dt.compania = f.compania and dt.pac_id = f.pac_id and dt.fac_secuencia = f.admi_secuencia),'9999999990.00')) factotalamt, to_char(a.fecha_creacion, 'HH24MI') factimeHHMI, to_char(a.fecha_ingreso, 'yyyymmdd') admdateYYYYMMDD, to_char(a.fecha_egreso, 'yyyymmdd') facdateYYYYMMDD, to_char(a.fecha_creacion, 'yyyymmddhh12mi') facdatetYYYYMMDDHHMI, nvl((select nvl(icd10,get_cds_diagnostico_version(diagnostico,");
sbSql.append(empr.getColValue("icd_version"));
sbSql.append(",null)) as diagnostico from tbl_adm_diagnostico_x_admision dxa where dxa.admision = a.secuencia and dxa.pac_id = a.pac_id and dxa.tipo = 'I' and dxa.orden_diag = 1 AND ROWNUM=1), '000.0') ICD9BK, nvl(COALESCE((select nvl(icd10,get_cds_diagnostico_version(diagnostico,");
sbSql.append(empr.getColValue("icd_version"));
sbSql.append(",null)) as diagnostico from tbl_adm_diagnostico_x_admision dxa where dxa.admision = a.secuencia and dxa.pac_id = a.pac_id and dxa.tipo = 'I' and dxa.orden_diag = 2 AND ROWNUM=1), (select nvl(icd10,get_cds_diagnostico_version(diagnostico,");
sbSql.append(empr.getColValue("icd_version"));
sbSql.append(",null)) as diagnostico from tbl_adm_diagnostico_x_admision dxa where dxa.admision = a.secuencia and dxa.pac_id = a.pac_id and dxa.tipo = 'I' and dxa.orden_diag = 1 AND ROWNUM=1)), '000.0') ICD9BJ, nvl(COALESCE((select nvl(icd10,get_cds_diagnostico_version(diagnostico,");
sbSql.append(empr.getColValue("icd_version"));
sbSql.append(",null)) as diagnostico from tbl_adm_diagnostico_x_admision dxa where dxa.admision = a.secuencia and dxa.pac_id = a.pac_id and dxa.tipo = 'I' and dxa.orden_diag = 3 AND ROWNUM=1), (select nvl(icd10,get_cds_diagnostico_version(diagnostico,");
sbSql.append(empr.getColValue("icd_version"));
sbSql.append(",null)) as diagnostico from tbl_adm_diagnostico_x_admision dxa where dxa.admision = a.secuencia and dxa.pac_id = a.pac_id and dxa.tipo = 'I' and dxa.orden_diag = 2 AND ROWNUM=1), (select nvl(icd10,get_cds_diagnostico_version(diagnostico,");
sbSql.append(empr.getColValue("icd_version"));
sbSql.append(",null)) as diagnostico from tbl_adm_diagnostico_x_admision dxa where dxa.admision = a.secuencia and dxa.pac_id = a.pac_id and dxa.tipo = 'I' and dxa.orden_diag = 1 AND ROWNUM=1)), '000.0') ICD9BN, join(cursor((select replace(replace(replace(replace(replace(body, '@@CPT_REVCODE', d.revenue_code), '@@UNITPRICE',trim(to_char(d.monto,'9999999990.00'))), '@@CANTIDAD', d.cantidad), '@@FECHACARGODESDE', to_char(d.fecha_creacion_desde, 'yyyymmdd')), '@@FECHACARGOHASTA', to_char(d.fecha_creacion_hasta, 'yyyymmdd')) from tbl_fac_axa837_body b, (select d.compania, d.pac_id, d.fac_secuencia, get_map_axa_revenue_code(d.compania, to_char(a.categoria), d.centro_servicio, d.tipo_cargo, d.procedimiento, 'RC', get_map_rev_code_lista_env(d.compania, d.pac_id, d.fac_secuencia), d.inv_articulo) revenue_code, sum(d.monto * decode(d.tipo_transaccion, 'D', -d.cantidad, d.cantidad)) monto, sum(decode(d.tipo_transaccion, 'D', -d.cantidad, d.cantidad)) cantidad, min(d.fecha_cargo) fecha_creacion_desde, max(d.fecha_cargo) fecha_creacion_hasta from tbl_fac_detalle_transaccion d, tbl_adm_admision a where d.fac_secuencia = a.secuencia and d.pac_id = a.pac_id group by   d.compania, d.pac_id, d.fac_secuencia, get_map_axa_revenue_code(d.compania, to_char(a.categoria), d.centro_servicio, d.tipo_cargo, d.procedimiento, 'RC', get_map_rev_code_lista_env(d.compania, d.pac_id, d.fac_secuencia), d.inv_articulo)) d where d.compania = f.compania and d.fac_secuencia = f.admi_secuencia and d.pac_id = f.pac_id and b.id = 3)), '^') body_cargos, coalesce (substr(z.apartado_postal, 1, decode(instr(z.apartado_postal, '-'), 0, length(z.apartado_postal), instr(z.apartado_postal, '-')-1)), x.poliza) patientcode, z.primer_nombre dfirst_name, nvl (z.primer_apellido, z.apellido_de_casada) dlast_name, z.sexo dsexo, to_char(z.fecha_nacimiento, 'yyyymmdd') ddob, (substr(p.apartado_postal, instr(p.apartado_postal, '-')+1, length(p.apartado_postal))) cod_benef from tbl_fac_factura f, tbl_adm_admision a, tbl_adm_paciente p, (select pac_id, empresa, admision, poliza, num_aprobacion from tbl_adm_beneficios_x_admision where estado = 'A') x, (select compania, admision, pac_id, ref_id from tbl_adm_responsable r where /*principal = 'N' and*/ ref_type = get_sec_comp_param(r.compania, 'TP_CLIENTE_PAC') and estado = 'A') y, tbl_adm_paciente z, tbl_fac_lista_envio_det le where f.admi_codigo_paciente = p.codigo and f.admi_fecha_nacimiento = p.fecha_nacimiento and a.fecha_nacimiento = f.admi_fecha_nacimiento and a.codigo_paciente = f.admi_codigo_paciente and a.secuencia = f.admi_secuencia and f.estatus <> 'A' and f.facturar_a = 'E' and f.compania = ");
sbSql.append((String) session.getAttribute("_companyId"));
sbSql.append(" /*and f.arch_837 is null*/ and f.pac_id = x.pac_id(+) and f.admi_secuencia = x.admision(+) and f.cod_empresa = x.empresa(+) and f.compania = y.compania(+) and f.admi_secuencia = y.admision(+) and f.pac_id = y.pac_id(+) and coalesce(to_number(y.ref_id), f.pac_id) = z.pac_id and le.compania = f.compania and le.factura = f.codigo and le.id = ");
sbSql.append(id);
sbSql.append(" order by 4");
al = SQLMgr.getDataList(sbSql.toString());
System.out.println("sbSql=\n"+sbSql.toString());
int chl = 2;
StringBuffer sb = new StringBuffer();
StringBuffer sbX = new StringBuffer();
for(int i=0;i<al.size();i++){
	CommonDataObject cd = (CommonDataObject) al.get(i);
	sb = new StringBuffer();
	sb.append(sbP.toString());
	while (sb.toString().contains("@@chl")){
		sbX.append(sb.toString().replaceFirst("@@chl", ""+chl));
		sb = new StringBuffer();
		sb.append(sbX.toString());
		sbX = new StringBuffer();
		chl++;
	}
	sbText.append(sb.toString().replaceAll("@@last_name", cd.getColValue("last_name")).replaceAll("@@first_name", cd.getColValue("first_name")).replaceAll("@@dob", cd.getColValue("dob")).replaceAll("@@sexo", cd.getColValue("sexo")).replaceAll("@@residencia_direccion", cd.getColValue("residencia_direccion")).replaceAll("@@dueno", (cd.getColValue("dueno").equals("S")?"18":"")).replaceAll("@@facno",cd.getColValue("facno")).replaceAll("@@factotalamt",cd.getColValue("factotalamt")).replaceAll("@@factimeHHMI",cd.getColValue("factimeHHMI")).replaceAll("@@admdateYYYYMMDD",cd.getColValue("admdateYYYYMMDD")).replaceAll("@@facdateYYYYMMDD",cd.getColValue("facdateYYYYMMDD")).replaceAll("@@facdatetYYYYMMDDHHMI",cd.getColValue("facdatetYYYYMMDDHHMI")).replaceAll("@@ICD9BK",cd.getColValue("ICD9BK")).replaceAll("@@ICD9BJ",cd.getColValue("ICD9BJ")).replaceAll("@@ICD9BN",cd.getColValue("ICD9BN")).replaceAll("@@patientcode",cd.getColValue("patientcode")).replaceAll("@@dlast_name", cd.getColValue("dlast_name")).replaceAll("@@dfirst_name", cd.getColValue("dfirst_name")).replaceAll("@@ddob", cd.getColValue("ddob")).replaceAll("@@dsexo", cd.getColValue("dsexo")).replaceAll("@@cod_benef", cd.getColValue("cod_benef")));
	sbText.append(newLine);
	StringTokenizer stB = new StringTokenizer(cd.getColValue("body_cargos"), "^");
	int lineNumber = 1;
	while (stB.hasMoreTokens()) {
		String body_cargos = stB.nextToken(); 
		sbText.append(body_cargos.replaceAll("@@linenumber", ""+lineNumber));
		sbText.append(newLine);
		lineNumber++;
  }
	
	System.out.println("sb...\n"+sb.toString());	
}
StringTokenizer st = new StringTokenizer(sbText.toString(), "~");
int contReg = st.countTokens()-2;

sbText.append(sbF.toString().replaceAll("@@count_reg", ""+contReg).replaceAll("@@secuencia", cdo.getColValue("secuencia")));

TextFile tf = new TextFile();
boolean created = false;
String fileName = "axa837"+cdo.getColValue("secuencia")+".txt";
String docPath = ResourceBundle.getBundle("path").getString("docs.axa837").replace(ResourceBundle.getBundle("path").getString("root"),"");
path = ResourceBundle.getBundle("path").getString("docs.axa837")+java.io.File.separator;
if (useFtp){
	if (ftp.connect()){
		ftp.setRemoteDirectory(path);
		if (ftp.uploadStream(sbText.toString(),fileName)) created = true;
		else System.out.println("Unable to upload content to FTP server!");
		ftp.disconnect();
	} else System.out.println("Unable to connect to FTP server!");
} else {
	System.out.println("Creating TXT file: "+fileName+" in directory:"+docPath);
	tf.write(path+fileName,sbText.toString());
	tf.close();
	//CmnMgr.changePermission(path+fileName);
	created = true;
}

if(fg == null)fg ="FAC";
String dep = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
if (mode == null) mode = "add";
String fileName2 = "";
String docPath2 ="";
String docDesc="";

if(p.getColValue("det_cargos").trim().equals("S")){

FPMgr.setConnection(ConMgr);
docPath2 = ResourceBundle.getBundle("path").getString("docs.axa837").replace(ResourceBundle.getBundle("path").getString("root"),"");

    //cdo = new CommonDataObject() ;
 
	cdo.addColValue("compania",(String) session.getAttribute("_companyId")); 
	cdo.addColValue("fg","AXA");
	cdo.addColValue("name","axa837_DC_"+cdo.getColValue("secuencia"));
	cdo.addColValue("extension",".csv");
	cdo.addColValue("vista","CCC");
	cdo.addColValue("docPath","axa837"); 
	
	
	  sbSql = new StringBuffer();
	  sbSql.append(" select 'invoice_no'||','||'hospital_name'||','||'provider_idcode'||','||'insured_cedula'||','||'insured_idnumber'||','||'insured_firstname'||','||'insured_lastname'||','||'dateofbirth'||','||'address'||','||'city'||','||'physician_firstname'||','||'physician_lastname'||','||'account_type'||','||'admit_date'||','||'discharge_date'||','||'startdate_of_service'||','||'enddate_of_service'||','||'revenue_code'||','||'cpt_code'||','||'units'||','||'unit_cost'||','||'total_charge'||','||'place_of_service'||','||'icd_code'||','||'serviceprocedure_name' as texto,1 ord,' ' fact,' ' descripcion from dual  union all select substr(f.codigo,1,12)||','||replace(substr((select nombre from tbl_sec_compania where codigo=f.compania),1,25),',',' ') ||','||replace((select cod_ref from tbl_adm_empresa where codigo =f.cod_empresa ),',',' ')||','|| replace(substr(z.id_paciente_f3,1,12),',',' ')||','||replace(substr(coalesce(substr(z.apartado_postal, 1, decode(instr(z.apartado_postal, '-'), 0, length(z.apartado_postal), instr(z.apartado_postal, '-')-1)), x.poliza),1,12),',',' ')||','||replace(substr(z.primer_nombre,1,20),',',' ')||','||replace(substr(z.primer_apellido,1,20),',',' ')||','||to_char(z.f_nac, 'dd/mm/yyyy')||','||replace(nvl ( substr (z.residencia_direccion, 1, 30), 'S/D'),',',' ')||','||replace(nvl ( substr (((select d.nombre from tbl_sec_provincia d where d.pais = z.residencia_pais and d.codigo= z.residencia_provincia)), 1, 15), 'S/D'),',',' ')||','||replace(substr ((select d.primer_nombre||' '||d.segundo_nombre from tbl_adm_medico d where codigo=a.medico),1,20),',',' ')||','||replace(substr ((select d.primer_apellido||' '||d.segundo_apellido||' '||d.apellido_de_casada from tbl_adm_medico  d where codigo=a.medico ),1,20),',',' ') ||','||decode(a.adm_type,'I', 111, 131 )||','||to_char(a.fecha_ingreso, 'dd/mm/yyyy') ||','||to_char(a.fecha_egreso, 'dd/mm/yyyy') ||','||to_char(fdt.fecha_cargo, 'dd/mm/yyyy')||','||to_char(fdt.fecha_cargo, 'dd/mm/yyyy')||','||substr (get_map_axa_revenue_code( f.compania, to_char(a.categoria), fdt.centro_servicio, fdt.tipo_cargo, fdt.procedimiento, 'RC', get_map_rev_code_lista_env(f.compania,f.pac_id, fdt.fac_secuencia), fdt.inv_articulo),1,3)||','||replace(substr(coalesce (fdt.procedimiento,fdt.habitacion, '' || fdt.cds_producto, '' || fdt.cod_uso, '' || fdt.otros_cargos, '' || fdt.cod_paq_x_cds, decode (fdt.inv_articulo, null, '', fdt.inv_articulo), ' '),1,8),',',' ')||','||sum(decode(fdt.tipo_transaccion,'D',-1*fdt.cantidad,fdt.cantidad))||','||trim(to_char(fdt.monto,'9999999990.00'))||','||trim(to_char((sum(decode(fdt.tipo_transaccion,'D',-1*fdt.cantidad,fdt.cantidad)) * (fdt.monto+nvl(fdt.recargo,0))),'9999999990.00'))||','||decode(a.adm_type,'I',21,decode(a.categoria,get_sec_comp_param(f.compania,'CAT_EGY'),23,22))||','||replace(substr(nvl( (select nvl(icd10,get_cds_diagnostico_version(diagnostico,10,null)) as diagnostico from tbl_adm_diagnostico_x_admision dxa where dxa.admision = a.secuencia and dxa.pac_id = a.pac_id and dxa.tipo = 'I' and dxa.orden_diag = 1 AND ROWNUM=1), '000.0'),1,8),',',' ')||','||replace(substr(fdt.descripcion,1,70),',',' ') as texto,2,f.codigo,fdt.descripcion   from tbl_fac_factura f, tbl_adm_admision a, vw_adm_paciente z,tbl_fac_lista_envio_det le,tbl_fac_detalle_transaccion fdt,(select pac_id, empresa, admision, poliza, num_aprobacion from tbl_adm_beneficios_x_admision where estado = 'A' ) x where a.pac_id = f.pac_id and a.secuencia = f.admi_secuencia and f.estatus <> 'A' and f.facturar_a = 'E' and f.compania = ");
sbSql.append(session.getAttribute("_companyId")); 
sbSql.append(" and fdt.pac_id =f.pac_id and fdt.fac_secuencia=f.admi_secuencia and fdt.compania=f.compania and f.pac_id = z.pac_id and le.compania = f.compania and le.factura = f.codigo and f.pac_id = x.pac_id(+) and f.admi_secuencia = x.admision(+) and f.cod_empresa = x.empresa(+)and le.id = ");
 sbSql.append(id);
 sbSql.append(" group by z.residencia_pais, z.residencia_provincia,z.id_paciente_f3,f.codigo,f.compania,f.cod_empresa,a.secuencia,a.pac_id,coalesce(substr(z.apartado_postal, 1, decode(instr(z.apartado_postal, '-'), 0, length(z.apartado_postal), instr(z.apartado_postal, '-')-1)), x.poliza), z.primer_nombre, z.primer_apellido,to_char(z.f_nac, 'dd/mm/yyyy'),nvl ( substr (z.residencia_direccion, 1, 30), 'S/D'),nvl ( substr (z.residencia_direccion, 1, 15), 'S/D'),a.medico,decode(a.adm_type,'I', 111, 131 ),to_char(a.fecha_ingreso, 'dd/mm/yyyy'),to_char(a.fecha_egreso, 'dd/mm/yyyy'),to_char(fdt.fecha_cargo, 'dd/mm/yyyy'),to_char(fdt.fecha_cargo, 'dd/mm/yyyy'),to_char(a.categoria), fdt.centro_servicio, fdt.tipo_cargo, fdt.procedimiento, fdt.inv_articulo, f.pac_id, fdt.fac_secuencia, coalesce (fdt.procedimiento,fdt.habitacion, '' || fdt.cds_producto, '' || fdt.cod_uso, '' || fdt.otros_cargos, '' || fdt.cod_paq_x_cds, decode (fdt.inv_articulo, null, '', fdt.inv_articulo), ' ') ,fdt.monto,decode(a.adm_type,'I',21,decode(a.categoria,get_sec_comp_param(f.compania,'CAT_EGY'),23,22)),fdt.descripcion  ,(fdt.monto+nvl(fdt.recargo,0)) order by 2, 3,4 ");
	  
	  
    fileName2 = FPMgr.createFile(cdo,sbSql.toString(),false);
	if (fileName2 == null) throw new Exception(FPMgr.getErrException());
	docDesc = "DETALLE CARGOS"; 

	  
}

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Envio de Lista- "+document.title;
function showEmpresa()
{
 var fecha = document.form0.fecha.value;
 if(fecha=='')CBMSG.warning('Seleccione fecha de Envío');
 else abrir_ventana1('../common/search_empresa.jsp?fp=listaEnvio&fEnvio='+fecha);
}

</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ENVIO DE LISTA"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("id",id)%>
			<%//fb.appendJsValidation("if(document."+fb.getFormName()+".existe.value=='N'){alert('El numero de lista No existe Verifique!');}");%>

			<tr class="TextHeader">
				<td colspan="4"><cellbytelabel>AXA837</cellbytelabel></td>
			</tr>
			<%if(created){%>
			<tr class="TextRow01">
			<td colspan="4" align="center"><cellbytelabel>Para descargar el archivo haga</cellbytelabel> <a href="<%=request.getContextPath()%><%=docPath%>/<%=fileName%>" class="Link00"><cellbytelabel>click aqu&iacute;</cellbytelabel> &nbsp;&nbsp;(<cellbytelabel>Para abrir</cellbytelabel>)</a>&nbsp;(<cellbytelabel>Click Derecho (guardar Destino como)</cellbytelabel>)&nbsp;&nbsp;
			<%if(p.getColValue("det_cargos").trim().equals("S")){%>
			 <a href="<%=request.getContextPath()%><%=docPath2%>/<%=fileName2%>" class="Link00"><cellbytelabel>Detalle De Cargos</cellbytelabel> &nbsp;&nbsp;(<cellbytelabel>Para abrir</cellbytelabel>)</a>&nbsp;(<cellbytelabel>Click Derecho (guardar Destino como)</cellbytelabel>) <%}%>
			</td>
		</tr>
			<%}%>
			<tr class="">
				<td colspan="4"><pre><%=sbText.toString()%></pre></td>
			</tr>

			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
				 <%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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


  String baction = request.getParameter("baction");
  String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

 
%>
<html>
<head>
<%@ include file="../common/header_param_min.jsp"%>
<script language="javascript">
function closeWindow()
{}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
