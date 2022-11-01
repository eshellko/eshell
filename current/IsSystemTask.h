#define ST_ACOS                 1
#define ST_ACOSH                (1+ST_ACOS)
#define ST_ASIN                 (1+ST_ACOSH)
#define ST_ASINH                (1+ST_ASIN)
#define ST_ASSERTCONTROL        (1+ST_ASINH)
#define ST_ASSERTFAILOFF        (1+ST_ASSERTCONTROL)
#define ST_ASSERTFAILON         (1+ST_ASSERTFAILOFF)
#define ST_ASSERTKILL           (1+ST_ASSERTFAILON)
#define ST_ASSERTNONVACUOUSON   (1+ST_ASSERTKILL)
#define ST_ASSERTOFF            (1+ST_ASSERTNONVACUOUSON)
#define ST_ASSERTON             (1+ST_ASSERTOFF)
#define ST_ASSERTPASSOFF        (1+ST_ASSERTON)
#define ST_ASSERTPASSON         (1+ST_ASSERTPASSOFF)
#define ST_ASSERTVACUOUSOFF     (1+ST_ASSERTPASSON)
#define ST_ASYNC_AND_ARRAY      (1+ST_ASSERTVACUOUSOFF)
#define ST_ASYNC_AND_PLANE      (1+ST_ASYNC_AND_ARRAY)
#define ST_ASYNC_NAND_ARRAY     (1+ST_ASYNC_AND_PLANE)
#define ST_ASYNC_NAND_PLANE     (1+ST_ASYNC_NAND_ARRAY)
#define ST_ASYNC_NOR_ARRAY      (1+ST_ASYNC_NAND_PLANE)
#define ST_ASYNC_NOR_PLANE      (1+ST_ASYNC_NOR_ARRAY)
#define ST_ASYNC_OR_ARRAY       (1+ST_ASYNC_NOR_PLANE)
#define ST_ASYNC_OR_PLANE       (1+ST_ASYNC_OR_ARRAY)
#define ST_ATAN                 (1+ST_ASYNC_OR_PLANE)
#define ST_ATAN2                (1+ST_ATAN)
#define ST_ATANH                (1+ST_ATAN2)
#define ST_BITS                 (1+ST_ATANH)
#define ST_BITSTOSHORTREAL      (1+ST_BITS)
#define ST_BITSTOREAL           (1+ST_BITSTOSHORTREAL)
#define ST_CAST                 (1+ST_BITSTOREAL)
#define ST_CEIL                 (1+ST_CAST)
#define ST_CHANGED              (1+ST_CEIL)
#define ST_CHANGED_GCLK         (1+ST_CHANGED)
#define ST_CHANGING_GCLK        (1+ST_CHANGED_GCLK)
#define ST_CLOG2                (1+ST_CHANGING_GCLK)
#define ST_COS                  (1+ST_CLOG2)
#define ST_COSH                 (1+ST_COS)
#define ST_COUNTBITS            (1+ST_COSH)
#define ST_COUNTONES            (1+ST_COUNTBITS)
#define ST_COVERAGE_CONTROL     (1+ST_COUNTONES)
#define ST_COVERAGE_GET         (1+ST_COVERAGE_CONTROL)
#define ST_COVERAGE_GET_MAX     (1+ST_COVERAGE_GET)
#define ST_COVERAGE_MERGE       (1+ST_COVERAGE_GET_MAX)
#define ST_COVERAGE_SAVE        (1+ST_COVERAGE_MERGE)
#define ST_DIMENSIONS           (1+ST_COVERAGE_SAVE)
#define ST_DISPLAY              (1+ST_DIMENSIONS)
#define ST_DISPLAYB             (1+ST_DISPLAY)
#define ST_DISPLAYH             (1+ST_DISPLAYB)
#define ST_DISPLAYO             (1+ST_DISPLAYH)
#define ST_DIST_CHI_SQUARE      (1+ST_DISPLAYO)
#define ST_DIST_ERLANG          (1+ST_DIST_CHI_SQUARE)
#define ST_DIST_EXPONENTIAL     (1+ST_DIST_ERLANG)
#define ST_DIST_NORMAL          (1+ST_DIST_EXPONENTIAL)
#define ST_DIST_POISSON         (1+ST_DIST_NORMAL)
#define ST_DIST_T               (1+ST_DIST_POISSON)
#define ST_DIST_UNIFORM         (1+ST_DIST_T)
#define ST_ERROR                (1+ST_DIST_UNIFORM)
#define ST_EXIT                 (1+ST_ERROR)
#define ST_EXP                  (1+ST_EXIT)
#define ST_FALLING_GCLK         (1+ST_EXP)
#define ST_FATAL                (1+ST_FALLING_GCLK)
#define ST_FCLOSE               (1+ST_FATAL)
#define ST_FDISPLAY             (1+ST_FCLOSE)
#define ST_FDISPLAYB            (1+ST_FDISPLAY)
#define ST_FDISPLAYH            (1+ST_FDISPLAYB)
#define ST_FDISPLAYO            (1+ST_FDISPLAYH)
#define ST_FELL                 (1+ST_FDISPLAYO)
#define ST_FELL_GCLK            (1+ST_FELL)
#define ST_FEOF                 (1+ST_FELL_GCLK)
#define ST_FERROR               (1+ST_FEOF)
#define ST_FFLUSH               (1+ST_FERROR)
#define ST_FGETC                (1+ST_FFLUSH)
#define ST_FGETS                (1+ST_FGETC)
#define ST_FINISH               (1+ST_FGETS)
#define ST_FLOOR                (1+ST_FINISH)
#define ST_FMONITOR             (1+ST_FLOOR)
#define ST_FMONITORB            (1+ST_FMONITOR)
#define ST_FMONITORH            (1+ST_FMONITORB)
#define ST_FMONITORO            (1+ST_FMONITORH)
#define ST_FOPEN                (1+ST_FMONITORO)
#define ST_FREAD                (1+ST_FOPEN)
#define ST_FSCANF               (1+ST_FREAD)
#define ST_FSEEK                (1+ST_FSCANF)
#define ST_FSTROBE              (1+ST_FSEEK)
#define ST_FSTROBEB             (1+ST_FSTROBE)
#define ST_FSTROBEH             (1+ST_FSTROBEB)
#define ST_FSTROBEO             (1+ST_FSTROBEH)
#define ST_FTELL                (1+ST_FSTROBEO)
#define ST_FUTURE_GCLK          (1+ST_FTELL)
#define ST_FWRITE               (1+ST_FUTURE_GCLK)
#define ST_FWRITEB              (1+ST_FWRITE)
#define ST_FWRITEH              (1+ST_FWRITEB)
#define ST_FWRITEO              (1+ST_FWRITEH)
#define ST_GET_COVERAGE         (1+ST_FWRITEO)
#define ST_HIGH                 (1+ST_GET_COVERAGE)
#define ST_HYPOT                (1+ST_HIGH)
#define ST_INCREMENT            (1+ST_HYPOT)
#define ST_INFO                 (1+ST_INCREMENT)
#define ST_ISUNBOUNDED          (1+ST_INFO)
#define ST_ISUNKNOWN            (1+ST_ISUNBOUNDED)
#define ST_ITOR                 (1+ST_ISUNKNOWN)
#define ST_LEFT                 (1+ST_ITOR)
#define ST_LN                   (1+ST_LEFT)
#define ST_LOAD_COVERAGE_DB     (1+ST_LN)
#define ST_LOG10                (1+ST_LOAD_COVERAGE_DB)
#define ST_LOW                  (1+ST_LOG10)
#define ST_MONITOR              (1+ST_LOW)
#define ST_MONITORB             (1+ST_MONITOR)
#define ST_MONITORH             (1+ST_MONITORB)
#define ST_MONITORO             (1+ST_MONITORH)
#define ST_MONITOROFF           (1+ST_MONITORO)
#define ST_MONITORON            (1+ST_MONITOROFF)
#define ST_ONEHOT               (1+ST_MONITORON)
#define ST_ONEHOT0              (1+ST_ONEHOT)
#define ST_PAST                 (1+ST_ONEHOT0)
#define ST_PAST_GCLK            (1+ST_PAST)
#define ST_POW                  (1+ST_PAST_GCLK)
#define ST_PRINTTIMESCALE       (1+ST_POW)
#define ST_Q_ADD                (1+ST_PRINTTIMESCALE)
#define ST_Q_EXAM               (1+ST_Q_ADD)
#define ST_Q_FULL               (1+ST_Q_EXAM)
#define ST_Q_INITIALIZE         (1+ST_Q_FULL)
#define ST_Q_REMOVE             (1+ST_Q_INITIALIZE)
#define ST_RANDOM               (1+ST_Q_REMOVE)
#define ST_READMEMB             (1+ST_RANDOM)
#define ST_READMEMH             (1+ST_READMEMB)
#define ST_REALTIME             (1+ST_READMEMH)
#define ST_REALTOBITS           (1+ST_REALTIME)
#define ST_REWIND               (1+ST_REALTOBITS)
#define ST_RIGHT                (1+ST_REWIND)
#define ST_RISING_GCLK          (1+ST_RIGHT)
#define ST_ROSE                 (1+ST_RISING_GCLK)
#define ST_ROSE_GCLK            (1+ST_ROSE)
#define ST_RTOI                 (1+ST_ROSE_GCLK)
#define ST_SAMPLED              (1+ST_RTOI)
#define ST_SDF_ANNOTATE         (1+ST_SAMPLED)
#define ST_SET_COVERAGE_DB_NAME (1+ST_SDF_ANNOTATE)
#define ST_SFORMAT              (1+ST_SET_COVERAGE_DB_NAME)
#define ST_SHORTREALTOBITS      (1+ST_SFORMAT)
#define ST_SIGNED               (1+ST_SHORTREALTOBITS)
#define ST_SIN                  (1+ST_SIGNED)
#define ST_SINH                 (1+ST_SIN)
#define ST_SIZE                 (1+ST_SINH)
#define ST_SQRT                 (1+ST_SIZE)
#define ST_SSCANF               (1+ST_SQRT)
#define ST_STABLE               (1+ST_SSCANF)
#define ST_STABLE_GCLK          (1+ST_STABLE)
#define ST_STEADY_GCLK          (1+ST_STABLE_GCLK)
#define ST_STIME                (1+ST_STEADY_GCLK)
#define ST_STOP                 (1+ST_STIME)
#define ST_STROBE               (1+ST_STOP)
#define ST_STROBEB              (1+ST_STROBE)
#define ST_STROBEH              (1+ST_STROBEB)
#define ST_STROBEO              (1+ST_STROBEH)
#define ST_SYSTEM               (1+ST_STROBEO)
#define ST_SYNC_AND_ARRAY       (1+ST_SYSTEM)
#define ST_SYNC_AND_PLANE       (1+ST_SYNC_AND_ARRAY)
#define ST_SYNC_NAND_ARRAY      (1+ST_SYNC_AND_PLANE)
#define ST_SYNC_NAND_PLANE      (1+ST_SYNC_NAND_ARRAY)
#define ST_SYNC_NOR_ARRAY       (1+ST_SYNC_NAND_PLANE)
#define ST_SYNC_NOR_PLANE       (1+ST_SYNC_NOR_ARRAY)
#define ST_SUNC_OR_ARRAY        (1+ST_SYNC_NOR_PLANE)
#define ST_SYNC_OR_PLANE        (1+ST_SUNC_OR_ARRAY)
#define ST_SWRITE               (1+ST_SYNC_OR_PLANE)
#define ST_SWRITEB              (1+ST_SWRITE)
#define ST_SWRITEH              (1+ST_SWRITEB)
#define ST_SWRITEO              (1+ST_SWRITEH)
#define ST_TAN                  (1+ST_SWRITEO)
#define ST_TANH                 (1+ST_TAN)
#define ST_TEST_PLUSARGS        (1+ST_TANH)
#define ST_TIME                 (1+ST_TEST_PLUSARGS)
#define ST_TIMEFORMAT           (1+ST_TIME)
#define ST_TYPENAME             (1+ST_TIMEFORMAT)
#define ST_UNGETC               (1+ST_TYPENAME)
#define ST_UNPACKED_DIMENSIONS  (1+ST_UNGETC)
#define ST_UNSIGNED             (1+ST_UNPACKED_DIMENSIONS)
#define ST_VALUE_PLUSARGS       (1+ST_UNSIGNED)
#define ST_WARNING              (1+ST_VALUE_PLUSARGS)
#define ST_WRITE                (1+ST_WARNING)
#define ST_WRITEB               (1+ST_WRITE)
#define ST_WRITEH               (1+ST_WRITEB)
#define ST_WRITEO               (1+ST_WRITEH)


const int NEW_ST_1800_2017 [] = {
   ST_ACOS,                 ST_ACOSH,            ST_ASIN,             ST_ASINH,               ST_ASSERTCONTROL,
   ST_ASSERTFAILOFF,        ST_ASSERTFAILON,     ST_ASSERTKILL,       ST_ASSERTNONVACUOUSON,  ST_ASSERTOFF,
   ST_ASSERTON,             ST_ASSERTPASSOFF,    ST_ASSERTPASSON,     ST_ASSERTVACUOUSOFF,    ST_ASYNC_AND_ARRAY,
   ST_ASYNC_AND_PLANE,      ST_ASYNC_NAND_ARRAY, ST_ASYNC_NAND_PLANE, ST_ASYNC_NOR_ARRAY,     ST_ASYNC_NOR_PLANE,
   ST_ASYNC_OR_ARRAY,       ST_ASYNC_OR_PLANE,   ST_ATAN,             ST_ATAN2,               ST_ATANH,
   ST_BITS,                 ST_BITSTOSHORTREAL,  ST_BITSTOREAL,       ST_CAST,                ST_CEIL,
   ST_CHANGED,              ST_CHANGED_GCLK,     ST_CHANGING_GCLK,    ST_CLOG2,               ST_COS,
   ST_COSH,                 ST_COUNTBITS,        ST_COUNTONES,        ST_COVERAGE_CONTROL,    ST_COVERAGE_GET,
   ST_COVERAGE_GET_MAX,     ST_COVERAGE_MERGE,   ST_COVERAGE_SAVE,    ST_DIMENSIONS,          ST_DISPLAY,
   ST_DISPLAYB,             ST_DISPLAYH,         ST_DISPLAYO,         ST_DIST_CHI_SQUARE,     ST_DIST_ERLANG,
   ST_DIST_EXPONENTIAL,     ST_DIST_NORMAL,      ST_DIST_POISSON,     ST_DIST_T,              ST_DIST_UNIFORM,
   ST_ERROR,                ST_EXIT,             ST_EXP,              ST_FALLING_GCLK,        ST_FATAL,
   ST_FCLOSE,               ST_FDISPLAY,         ST_FDISPLAYB,        ST_FDISPLAYH,           ST_FDISPLAYO,
   ST_FELL,                 ST_FELL_GCLK,        ST_FEOF,             ST_FERROR,              ST_FFLUSH,
   ST_FGETC,                ST_FGETS,            ST_FINISH,           ST_FLOOR,               ST_FMONITOR,
   ST_FMONITORB,            ST_FMONITORH,        ST_FMONITORO,        ST_FOPEN,               ST_FREAD,
   ST_FSCANF,               ST_FSEEK,            ST_FSTROBE,          ST_FSTROBEB,            ST_FSTROBEH,
   ST_FSTROBEO,             ST_FTELL,            ST_FUTURE_GCLK,      ST_FWRITE,              ST_FWRITEB,
   ST_FWRITEH,              ST_FWRITEO,          ST_GET_COVERAGE,     ST_HIGH,                ST_HYPOT,
   ST_INCREMENT,            ST_INFO,             ST_ISUNBOUNDED,      ST_ISUNKNOWN,           ST_ITOR,
   ST_LEFT,                 ST_LN,               ST_LOAD_COVERAGE_DB, ST_LOG10,               ST_LOW,
   ST_MONITOR,              ST_MONITORB,         ST_MONITORH,         ST_MONITORO,            ST_MONITOROFF,
   ST_MONITORON,            ST_ONEHOT,           ST_ONEHOT0,          ST_PAST,                ST_PAST_GCLK,
   ST_POW,                  ST_PRINTTIMESCALE,   ST_Q_ADD,            ST_Q_EXAM,              ST_Q_FULL,
   ST_Q_INITIALIZE,         ST_Q_REMOVE,         ST_RANDOM,           ST_READMEMB,            ST_READMEMH,
   ST_REALTIME,             ST_REALTOBITS,       ST_REWIND,           ST_RIGHT,               ST_RISING_GCLK,
   ST_ROSE,                 ST_ROSE_GCLK,        ST_RTOI,             ST_SAMPLED,             ST_SDF_ANNOTATE,
   ST_SET_COVERAGE_DB_NAME, ST_SFORMAT,          ST_SHORTREALTOBITS,  ST_SIGNED,              ST_SIN,
   ST_SINH,                 ST_SIZE,             ST_SQRT,             ST_SSCANF,              ST_STABLE,
   ST_STABLE_GCLK,          ST_STEADY_GCLK,      ST_STIME,            ST_STOP,                ST_STROBE,
   ST_STROBEB,              ST_STROBEH,          ST_STROBEO,          ST_SYNC_AND_ARRAY,      ST_SYNC_AND_PLANE,
   ST_SYNC_NAND_ARRAY,      ST_SYNC_NAND_PLANE,  ST_SYNC_NOR_ARRAY,   ST_SYNC_NOR_PLANE,      ST_SUNC_OR_ARRAY,
   ST_SYNC_OR_PLANE,        ST_SYSTEM,           ST_SWRITE,           ST_SWRITEB,             ST_SWRITEH,
   ST_SWRITEO,              ST_TAN,              ST_TANH,             ST_TEST_PLUSARGS,       ST_TIME,
   ST_TIMEFORMAT,           ST_TYPENAME,         ST_UNGETC,           ST_UNPACKED_DIMENSIONS, ST_UNSIGNED,
   ST_VALUE_PLUSARGS,       ST_WARNING,          ST_WRITE,            ST_WRITEB,              ST_WRITEH,
   ST_WRITEO
};

const int NEW_ST_1364_2001 [] = {
   ST_ACOS,                 ST_ACOSH,            ST_ASIN,             ST_ASINH,               0/*ST_ASSERTCONTROL*/,
   0/*ST_ASSERTFAILOFF*/,        0/*ST_ASSERTFAILON*/,     0/*ST_ASSERTKILL*/,       0/*ST_ASSERTNONVACUOUSON*/,  0/*ST_ASSERTOFF*/,
   0/*ST_ASSERTON*/,             0/*ST_ASSERTPASSOFF*/,    0/*ST_ASSERTPASSON*/,     0/*ST_ASSERTVACUOUSOFF*/,    ST_ASYNC_AND_ARRAY,
   ST_ASYNC_AND_PLANE,      ST_ASYNC_NAND_ARRAY, ST_ASYNC_NAND_PLANE, ST_ASYNC_NOR_ARRAY,     ST_ASYNC_NOR_PLANE,
   ST_ASYNC_OR_ARRAY,       ST_ASYNC_OR_PLANE,   ST_ATAN,             ST_ATAN2,               ST_ATANH,
   0/*ST_BITS*/,                 0/*ST_BITSTOSHORTREAL*/,  ST_BITSTOREAL,       ST_CAST,                ST_CEIL,
   0/*ST_CHANGED*/,              0/*ST_CHANGED_GCLK*/,     0/*ST_CHANGING_GCLK*/,    ST_CLOG2,               ST_COS,
   ST_COSH,                 0/*ST_COUNTBITS*/,        0/*ST_COUNTONES*/,        0/*ST_COVERAGE_CONTROL*/,    0/*ST_COVERAGE_GET*/,
   0/*ST_COVERAGE_GET_MAX*/,     0/*ST_COVERAGE_MERGE*/,   0/*ST_COVERAGE_SAVE*/,    0/*ST_DIMENSIONS*/,          ST_DISPLAY,
   ST_DISPLAYB,             ST_DISPLAYH,         ST_DISPLAYO,         ST_DIST_CHI_SQUARE,     ST_DIST_ERLANG,
   ST_DIST_EXPONENTIAL,     ST_DIST_NORMAL,      ST_DIST_POISSON,     ST_DIST_T,              ST_DIST_UNIFORM,
   0/*ST_ERROR*/,                0/*ST_EXIT*/,             ST_EXP,              0/*ST_FALLING_GCLK*/,        0/*ST_FATAL*/,
   ST_FCLOSE,               ST_FDISPLAY,         ST_FDISPLAYB,        ST_FDISPLAYH,           ST_FDISPLAYO,
   0/*ST_FELL*/,                 0/*ST_FELL_GCLK*/,        ST_FEOF,             ST_FERROR,              ST_FFLUSH,
   ST_FGETC,                ST_FGETS,            ST_FINISH,           ST_FLOOR,               ST_FMONITOR,
   ST_FMONITORB,            ST_FMONITORH,        ST_FMONITORO,        ST_FOPEN,               ST_FREAD,
   ST_FSCANF,               ST_FSEEK,            ST_FSTROBE,          ST_FSTROBEB,            ST_FSTROBEH,
   ST_FSTROBEO,             ST_FTELL,            0/*ST_FUTURE_GCLK*/,      ST_FWRITE,              ST_FWRITEB,
   ST_FWRITEH,              ST_FWRITEO,          0/*ST_GET_COVERAGE*/,     0/*ST_HIGH*/,                ST_HYPOT,
   0/*ST_INCREMENT*/,            0/*ST_INFO*/,             0/*ST_ISUNBOUNDED*/,      0/*ST_ISUNKNOWN*/,           ST_ITOR,
   0/*ST_LEFT*/,                 ST_LN,               0/*ST_LOAD_COVERAGE_DB*/, ST_LOG10,               0/*ST_LOW*/,
   ST_MONITOR,              ST_MONITORB,         ST_MONITORH,         ST_MONITORO,            ST_MONITOROFF,
   ST_MONITORON,            0/*ST_ONEHOT*/,           0/*ST_ONEHOT0*/,          0/*ST_PAST*/,                0/*ST_PAST_GCLK*/,
   ST_POW,                  ST_PRINTTIMESCALE,   ST_Q_ADD,            ST_Q_EXAM,              ST_Q_FULL,
   ST_Q_INITIALIZE,         ST_Q_REMOVE,         ST_RANDOM,           ST_READMEMB,            ST_READMEMH,
   ST_REALTIME,             ST_REALTOBITS,       ST_REWIND,           0/*ST_RIGHT*/,               0/*ST_RISING_GCLK*/,
   0/*ST_ROSE*/,                 0/*ST_ROSE_GCLK*/,        ST_RTOI,             0/*ST_SAMPLED*/,             ST_SDF_ANNOTATE,
   0/*ST_SET_COVERAGE_DB_NAME*/, ST_SFORMAT,          0/*ST_SHORTREALTOBITS*/,  ST_SIGNED,              ST_SIN,
   ST_SINH,                 0/*ST_SIZE*/,             ST_SQRT,             ST_SSCANF,              0/*ST_STABLE*/,
   0/*ST_STABLE_GCLK*/,          0/*ST_STEADY_GCLK*/,      ST_STIME,            ST_STOP,                ST_STROBE,
   ST_STROBEB,              ST_STROBEH,          ST_STROBEO,          ST_SYNC_AND_ARRAY,      ST_SYNC_AND_PLANE,
   ST_SYNC_NAND_ARRAY,      ST_SYNC_NAND_PLANE,  ST_SYNC_NOR_ARRAY,   ST_SYNC_NOR_PLANE,      ST_SUNC_OR_ARRAY,
   ST_SYNC_OR_PLANE,           0/*ST_SYSTEM*/,              ST_SWRITE,   ST_SWRITEB,              ST_SWRITEH,
   ST_SWRITEO,          ST_TAN,              ST_TANH,             ST_TEST_PLUSARGS,       ST_TIME,
   ST_TIMEFORMAT,           0/*ST_TYPENAME*/,         ST_UNGETC,           0/*ST_UNPACKED_DIMENSIONS*/, ST_UNSIGNED,
   ST_VALUE_PLUSARGS,       0/*ST_WARNING*/,          ST_WRITE,            ST_WRITEB,              ST_WRITEH,
   ST_WRITEO
};

int IsSystemTask(char* word)
{
// according to 'IEEE 1364-2005' Clause 17
// according to 'IEEE 1800-2017' Clause 20
// todo: resort return values alphabetically in usage functions (i+1) returned
   const char* kw_hash [181] =
   {
// todo: sort alphabetically
      "$acos", "$acosh", "$asin", "$asinh", "$assertcontrol", 
      "$assertcontroloff", "$assertfailon", "$assertkill", "$assertnonvacuouson", "$assertoff",
      "$asserton",          "$assertpassoff",    "$assertpasson",     "$assertvacuousoff",    "$async$and$array",
      "$async$and$plane", "$async$nand$array", "$async$nand$plane", "$async$nor$array", "$async$nor$plane",
      "$async$or$array", "$async$or$plane", "$atan", "$atan2", "$atanh",
      "$bits", "$bitstoshortreal", "$bitstoreal", "$cast", "$ceil",
      "$changed", "$changed_gclk", "$changing_gclk", "$clog2", "$cos", "$cosh",
      "$countbits",        "$countones",        "$coverage_control",    "$coverage_get",
      "$coverage_get_max",     "$coverage_merge",   "$coverage_save",    "dimensions",          "$display",
      "$displayb",             "$displayh",         "$displayo",         "$dist_chi_square",     "$dist_erlang",
      "$dist_exponential",     "$dist_normal", "$dist_poisson", "$dist_t",              "$dist_uniform",
      "$error",   "$exit", "$exp", "$falling_gclk", "$fatal",
      "$fclose", "$fdisplay", "$fdisplayb", "$fdisplayh", "$fdisplayo", "$fell", "$fell_gclk", "$feof", "$ferror", "$fflush",
      "$fgetc", "$fgets", "$finish", "$floor", "$fmonitor", "$fmonitorb", "$fmonitorh", "$fmonitoro", "$fopen", "$fread",
      "$fscanf", "$fseek", "$fstrobe", "$fstrobeb", "$fstrobeh", "$fstrobeo", "$ftell",
      "$future_gclk", "$fwrite", "$fwriteb", "$fwriteh",   "$fwriteo",
      "$get_coverage",    "$high",  "$hypot", "$increment",
      "$info",  "$isunbounded", "$isunknown", "$itor", "$left",
      "$ln", "$load_coverage_db", "$log10",  "$low",
      "$monitor", "$monitorb", "$monitorh", "$monitoro", "$monitoroff",
      "$monitoron", "$onehot", "$onehot0", "$past", "$past_gclk",
      "$pow", "$printtimescale", "$q_add", "$q_exam", "$q_full", "$q_initialize", "$q_remove", "$random", "$readmemb",
      "$readmemh", "$realtime", "$realtobits", "$rewind", "$right", "$rising_gclk",
      "$rose", "$rose_gclk",   "$rtoi", "$sampled", "$sdf_annotate",
      "$set_coverage_db_name", "$sformat",
      "$shortrealtobits", "$signed", "$sin", "$sinh", "$size", "$sqrt", "$sscanf",
      "$stable", "$stable_gclk", "$steady_gclk",  
      "$stime", "$stop", "$strobe", "$strobeb", "$strobeh", "$strobeo",
      "$sync$and$array", "$sync$and$plane", "$sync$nand$array", "$sync$nand$plane", "$sync$nor$array", "$sync$nor$plane", "$sync$or$array", "$sync$or$plane",
      "$system", "$swrite", "$swriteb",
      "$swriteh", "$swriteo",
      "$tan", "$tanh", "$test$plusargs", "$time",
      "$timeformat", "$typename",
      "$ungetc", "$unpacked_dimensions",
      "$unsigned",
      "$value$plusargs",         "$warning",                "$write", "$writeb",
      "$writeh", "$writeo"
   };
   // Note: Newton search algorithm; return value alphabetically sorted
   int num = sizeof(kw_hash) / sizeof(kw_hash[0]);
   int step = 32*2*2; // TODO: calculate as f(num)!!
   int i = num / 2;
   while(step)
   {
      step /= 2;
      int rv = strcmp(word, kw_hash[i]);
//eprint("%d - %s - %d\n", step, Word, i);
      if(rv == 0)
      {
//         int tm = i + 1;
         if(!(gmain->setting_vlog & BREAK_VLOG_ON_SYSTEMVERILOG))
            return NEW_ST_1800_2017[i];
         else
            return NEW_ST_1364_2001[i];
      }
      else if(rv < 0) i = i - step;
      else if(rv > 0) i = i + step;
      if(i > num-1) i = num-1;
      if(i < 0) i = 0;
   }

   return 0;
}
