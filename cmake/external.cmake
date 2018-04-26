# This file is part of COMP_hack.
#
# Copyright (C) 2010-2016 COMP_hack Team <compomega@tutanota.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Enable the ExternalProject CMake module.
INCLUDE(ExternalProject)

OPTION(GIT_DEPENDENCIES "Download dependencies from Git instead." OFF)

IF(WIN32)
    SET(CMAKE_RELWITHDEBINFO_OPTIONS -DCMAKE_RELWITHDEBINFO_POSTFIX=_reldeb)
ENDIF(WIN32)

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/GSL.zip")
    SET(GSL_URL
        URL "${CMAKE_SOURCE_DIR}/deps/GSL.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(GSL_URL
        GIT_REPOSITORY https://github.com/Microsoft/GSL.git
        GIT_TAG master
    )
ELSE()
    SET(GSL_URL
        URL https://github.com/Microsoft/GSL/archive/5905d2d77467d9daa18fe711b55e2db7a30fe3e3.zip
        URL_HASH SHA1=a2d2c6bfe101be3ef80d9c69e3361f164517e7b9
    )
ENDIF()

ExternalProject_Add(
    gsl

    ${GSL_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/gsl
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)

ExternalProject_Get_Property(gsl SOURCE_DIR)
ExternalProject_Get_Property(gsl INSTALL_DIR)

SET_TARGET_PROPERTIES(gsl PROPERTIES FOLDER "Dependencies")

#SET(GSL_INCLUDE_DIRS "${INSTALL_DIR}/include")
SET(GSL_INCLUDE_DIRS "${SOURCE_DIR}/include")

FILE(MAKE_DIRECTORY "${GSL_INCLUDE_DIRS}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/zlib.zip")
    SET(ZLIB_URL
        URL "${CMAKE_SOURCE_DIR}/deps/zlib.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(ZLIB_URL
        GIT_REPOSITORY https://github.com/comphack/zlib.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(ZLIB_URL
        URL https://github.com/comphack/zlib/archive/comp_hack-20180425.zip
        URL_HASH SHA1=41ef62fec86b9a4408d99c2e7ee1968a5e246e3b
    )
ENDIF()

ExternalProject_Add(
    zlib-lib

    ${ZLIB_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zlib
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DSKIP_INSTALL_FILES=ON -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME}

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/libz.a
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/zlibstatic.lib
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/zlibstaticd.lib
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/zlibstatic_reldeb.lib
)

ExternalProject_Get_Property(zlib-lib INSTALL_DIR)

SET_TARGET_PROPERTIES(zlib-lib PROPERTIES FOLDER "Dependencies")

SET(ZLIB_INCLUDES "${INSTALL_DIR}/include")
SET(ZLIB_LIBRARIES zlib)

FILE(MAKE_DIRECTORY "${ZLIB_INCLUDES}")

ADD_LIBRARY(zlib STATIC IMPORTED)
ADD_DEPENDENCIES(zlib zlib-lib)

IF(WIN32)
    SET_TARGET_PROPERTIES(zlib PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/zlibstatic.lib"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/zlibstatic_reldeb.lib"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/zlibstaticd.lib")
ELSE()
    SET_TARGET_PROPERTIES(zlib PROPERTIES
        IMPORTED_LOCATION "${INSTALL_DIR}/lib/libz.a")
ENDIF()

SET_TARGET_PROPERTIES(zlib PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${ZLIB_INCLUDES}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/openssl.zip")
    SET(OPENSSL_URL
        URL "${CMAKE_SOURCE_DIR}/deps/openssl.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(OPENSSL_URL
        GIT_REPOSITORY https://github.com/comphack/openssl.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(OPENSSL_URL
        URL https://github.com/comphack/openssl/archive/comp_hack-20180424.zip
        URL_HASH SHA1=0ac698894a8d9566a8d7982e32869252dc11d18b
    )
ENDIF()

ExternalProject_Add(
    openssl

    ${OPENSSL_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/openssl
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d -DBUILD_VALGRIND_FRIENDLY=${BUILD_VALGRIND_FRIENDLY}

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ssl${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}crypto${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ssleay32${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}libeay32${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ssleay32d${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}libeay32d${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ssleay32_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}libeay32_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(openssl INSTALL_DIR)

SET_TARGET_PROPERTIES(openssl PROPERTIES FOLDER "Dependencies")

SET(OPENSSL_INCLUDE_DIR "${INSTALL_DIR}/include")
SET(OPENSSL_ROOT_DIR "${INSTALL_DIR}")

FILE(MAKE_DIRECTORY "${OPENSSL_INCLUDE_DIR}")

IF(WIN32)
    SET(OPENSSL_LIBRARIES ssleay32 libeay32 crypt32)
ELSE()
    SET(OPENSSL_LIBRARIES ssl crypto)
ENDIF()

IF(WIN32)
    ADD_LIBRARY(ssleay32 STATIC IMPORTED)
    ADD_DEPENDENCIES(ssleay32 openssl)
    SET_TARGET_PROPERTIES(ssleay32 PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ssleay32${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ssleay32_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ssleay32d${CMAKE_STATIC_LIBRARY_SUFFIX}")

    SET_TARGET_PROPERTIES(ssleay32 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INCLUDE_DIR}")

    ADD_LIBRARY(libeay32 STATIC IMPORTED)
    ADD_DEPENDENCIES(libeay32 openssl)
    SET_TARGET_PROPERTIES(libeay32 PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}libeay32${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}libeay32_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}libeay32d${CMAKE_STATIC_LIBRARY_SUFFIX}")

    SET_TARGET_PROPERTIES(libeay32 PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INCLUDE_DIR}")
ELSE()
    ADD_LIBRARY(ssl STATIC IMPORTED)
    ADD_DEPENDENCIES(ssl openssl)
    SET_TARGET_PROPERTIES(ssl PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ssl${CMAKE_STATIC_LIBRARY_SUFFIX}")

    SET_TARGET_PROPERTIES(ssl PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INCLUDE_DIR}")

    ADD_LIBRARY(crypto STATIC IMPORTED)
    ADD_DEPENDENCIES(crypto openssl)
    SET_TARGET_PROPERTIES(crypto PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}crypto${CMAKE_STATIC_LIBRARY_SUFFIX}")

    SET_TARGET_PROPERTIES(crypto PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INCLUDE_DIR}")
ENDIF()

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/mariadb.zip")
    SET(MARIADB_URL
        URL "${CMAKE_SOURCE_DIR}/deps/mariadb.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(MARIADB_URL
        GIT_REPOSITORY https://github.com/comphack/mariadb.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(MARIADB_URL
        URL https://github.com/comphack/mariadb/archive/comp_hack-20180425.zip
        URL_HASH SHA1=e3cccd1ce7338ecf21864c507579d24f5c9a234a
    )
ENDIF()

ExternalProject_Add(
    mariadb

    ${MARIADB_URL}

    DEPENDS openssl

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/mariadb
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d -DWITH_OPENSSL=ON

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/mariadb/${CMAKE_STATIC_LIBRARY_PREFIX}mariadbclient${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/mariadb/${CMAKE_STATIC_LIBRARY_PREFIX}mariadbclientd${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/mariadb/${CMAKE_STATIC_LIBRARY_PREFIX}mariadbclient_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(mariadb INSTALL_DIR)

SET_TARGET_PROPERTIES(mariadb PROPERTIES FOLDER "Dependencies")

SET(MARIADB_INCLUDE_DIRS "${INSTALL_DIR}/include/mariadb")

FILE(MAKE_DIRECTORY "${MARIADB_INCLUDE_DIRS}")

ADD_LIBRARY(mariadbclient STATIC IMPORTED)
ADD_DEPENDENCIES(mariadbclient mariadb)

IF(WIN32)
    SET_TARGET_PROPERTIES(mariadbclient PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/mariadb/${CMAKE_STATIC_LIBRARY_PREFIX}mariadbclient${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/mariadb/${CMAKE_STATIC_LIBRARY_PREFIX}mariadbclient_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/mariadb/${CMAKE_STATIC_LIBRARY_PREFIX}mariadbclientd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(mariadbclient PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/mariadb/${CMAKE_STATIC_LIBRARY_PREFIX}mariadbclient${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(mariadbclient PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${MARIADB_INCLUDE_DIRS}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/ttvfs.zip")
    SET(TTVFS_URL
        URL "${CMAKE_SOURCE_DIR}/deps/ttvfs.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(TTVFS_URL
        GIT_REPOSITORY https://github.com/comphack/ttvfs.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(TTVFS_URL
        URL https://github.com/comphack/ttvfs/archive/comp_hack-20180424.zip
        URL_HASH SHA1=c3feca3b35109e9ad4ae61821f62df76a412b87f
    )
ENDIF()

ExternalProject_Add(
    ttvfs-ex

    ${TTVFS_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ttvfs
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfsd${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapid${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zipd${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(ttvfs-ex INSTALL_DIR)

SET_TARGET_PROPERTIES(ttvfs-ex PROPERTIES FOLDER "Dependencies")

SET(TTVFS_INCLUDE_DIRS "${INSTALL_DIR}/include")

FILE(MAKE_DIRECTORY "${TTVFS_INCLUDE_DIRS}")

ADD_LIBRARY(ttvfs STATIC IMPORTED)
ADD_DEPENDENCIES(ttvfs ttvfs-ex)

IF(WIN32)
    SET_TARGET_PROPERTIES(ttvfs PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfsd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(ttvfs PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(ttvfs PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

ADD_LIBRARY(ttvfs_cfileapi STATIC IMPORTED)
ADD_DEPENDENCIES(ttvfs_cfileapi ttvfs-ex)

IF(WIN32)
    SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapid${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

ADD_LIBRARY(ttvfs_zip STATIC IMPORTED)
ADD_DEPENDENCIES(ttvfs_zip ttvfs-ex)

IF(WIN32)
    SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zipd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

SET(TTVFS_GEN_PATH "${INSTALL_DIR}/bin/ttvfs_gen")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/physfs.zip")
    SET(PHYSFS_URL
        URL "${CMAKE_SOURCE_DIR}/deps/physfs.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(PHYSFS_URL
        GIT_REPOSITORY https://github.com/comphack/physfs.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(PHYSFS_URL
        URL https://github.com/comphack/physfs/archive/comp_hack-20180424.zip
        URL_HASH SHA1=46de8609129749fccd8bbed02b68d6966ebb5e9b
    )
ENDIF()

ExternalProject_Add(
    physfs-lib

    ${PHYSFS_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/physfs
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d -DPHYSFS_ARCHIVE_ZIP=FALSE -DPHYSFS_ARCHIVE_7Z=FALSE -DPHYSFS_ARCHIVE_GRP=FALSE -DPHYSFS_ARCHIVE_WAD=FALSE -DPHYSFS_ARCHIVE_HOG=FALSE -DPHYSFS_ARCHIVE_MVL=FALSE -DPHYSFS_ARCHIVE_QPAK=FALSE -DPHYSFS_BUILD_STATIC=TRUE -DPHYSFS_BUILD_SHARED=FALSE -DPHYSFS_BUILD_TEST=FALSE -DPHYSFS_BUILD_WX_TEST=FALSE -DPHYSFS_INTERNAL_ZLIB=TRUE

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}physfs${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}physfsd${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}physfs_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(physfs-lib INSTALL_DIR)

SET_TARGET_PROPERTIES(physfs-lib PROPERTIES FOLDER "Dependencies")

SET(PHYSFS_INCLUDE_DIRS "${INSTALL_DIR}/include")

FILE(MAKE_DIRECTORY "${PHYSFS_INCLUDE_DIRS}")

ADD_LIBRARY(physfs STATIC IMPORTED)
ADD_DEPENDENCIES(physfs physfs-lib)

IF(WIN32)
    SET_TARGET_PROPERTIES(physfs PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}physfs${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}physfs_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}physfsd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(physfs PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}physfs${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(physfs PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${PHYSFS_INCLUDE_DIRS}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/sqrat.zip")
    SET(SQRAT_URL
        URL "${CMAKE_SOURCE_DIR}/deps/sqrat.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(SQRAT_URL
        GIT_REPOSITORY https://github.com/comphack/sqrat.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(SQRAT_URL
        URL https://github.com/comphack/sqrat/archive/comp_hack-20170905.zip
        URL_HASH SHA1=6c4df47021866905632c5000a5359d2927604c4f
    )
ENDIF()

ExternalProject_Add(
    sqrat

    ${SQRAT_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/sqrat
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)

ExternalProject_Get_Property(sqrat INSTALL_DIR)

SET_TARGET_PROPERTIES(sqrat PROPERTIES FOLDER "Dependencies")

SET(SQRAT_INCLUDE_DIRS "${INSTALL_DIR}/include")
SET(SQRAT_DEFINES "-DSCRAT_USE_CXX11_OPTIMIZATIONS=1")

FILE(MAKE_DIRECTORY "${SQRAT_INCLUDE_DIRS}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/civetweb.zip")
    SET(CIVET_URL
        URL "${CMAKE_SOURCE_DIR}/deps/civetweb.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(CIVET_URL
        GIT_REPOSITORY https://github.com/comphack/civetweb.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(CIVET_URL
        URL https://github.com/comphack/civetweb/archive/comp_hack-20180424.zip
        URL_HASH SHA1=59cd1b9caab9b13bc1be9c7eea30f052edeb5e79
    )
ENDIF()

ExternalProject_Add(
    civet

    ${CIVET_URL}

    DEPENDS openssl

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/civetweb
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}" -DBUILD_TESTING=OFF -DCIVETWEB_LIBRARIES_ONLY=ON -DCIVETWEB_ENABLE_SLL=ON -DCIVETWEB_ENABLE_SSL_DYNAMIC_LOADING=OFF -DCIVETWEB_ALLOW_WARNINGS=ON -DCIVETWEB_ENABLE_CXX=ON "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}civetweb${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cxx-library${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}civetwebd${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cxx-libraryd${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}civetweb_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cxx-library_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(civet INSTALL_DIR)

SET_TARGET_PROPERTIES(civet PROPERTIES FOLDER "Dependencies")

SET(CIVETWEB_INCLUDE_DIRS "${INSTALL_DIR}/include")

FILE(MAKE_DIRECTORY "${CIVETWEB_INCLUDE_DIRS}")

ADD_LIBRARY(civetweb STATIC IMPORTED)
ADD_DEPENDENCIES(civetweb civet)

IF(WIN32)
    SET_TARGET_PROPERTIES(civetweb PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}civetweb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}civetweb_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}civetwebd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(civetweb PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}civetweb${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(civetweb PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CIVETWEB_INCLUDE_DIRS}")

ADD_LIBRARY(civetweb-cxx STATIC IMPORTED)
ADD_DEPENDENCIES(civetweb-cxx civetweb)

IF(WIN32)
    SET_TARGET_PROPERTIES(civetweb-cxx PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cxx-library${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cxx-library_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cxx-libraryd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(civetweb-cxx PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}cxx-library${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(civetweb-cxx PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CIVETWEB_INCLUDE_DIRS}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/squirrel3.zip")
    SET(SQUIRREL_URL
        URL "${CMAKE_SOURCE_DIR}/deps/squirrel3.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(SQUIRREL_URL
        GIT_REPOSITORY https://github.com/comphack/squirrel3.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(SQUIRREL_URL
        URL https://github.com/comphack/squirrel3/archive/comp_hack-20180424.zip
        URL_HASH SHA1=e93edb4d4d6efdc45afa6f51e36d1971934e676d
    )
ENDIF()

ExternalProject_Add(
    squirrel3

    ${SQUIRREL_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/squirrel3
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}squirrel${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sqstdlib${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}squirreld${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sqstdlibd${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}squirrel_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sqstdlib_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(squirrel3 INSTALL_DIR)

SET_TARGET_PROPERTIES(squirrel3 PROPERTIES FOLDER "Dependencies")

SET(SQUIRREL_INCLUDE_DIRS "${INSTALL_DIR}/include")

FILE(MAKE_DIRECTORY "${SQUIRREL_INCLUDE_DIRS}")

ADD_LIBRARY(squirrel STATIC IMPORTED)
ADD_DEPENDENCIES(squirrel squirrel3)

IF(WIN32)
    SET_TARGET_PROPERTIES(squirrel PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}squirrel${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}squirrel_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}squirreld${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(squirrel PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}squirrel${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(squirrel PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
    "${SQUIRREL_INCLUDE_DIRS};${SQRAT_INCLUDE_DIRS}")

ADD_LIBRARY(sqstdlib STATIC IMPORTED)
ADD_DEPENDENCIES(sqstdlib squirrel3)

IF(WIN32)
    SET_TARGET_PROPERTIES(sqstdlib PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sqstdlib${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sqstdlib_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sqstdlibd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(sqstdlib PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sqstdlib${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(sqstdlib PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
    "${SQUIRREL_INCLUDE_DIRS};${SQRAT_INCLUDE_DIRS}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/asio.zip")
    SET(ASIO_URL
        URL "${CMAKE_SOURCE_DIR}/deps/asio.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(ASIO_URL
        GIT_REPOSITORY https://github.com/comphack/asio.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(ASIO_URL
        URL https://github.com/comphack/asio/archive/comp_hack-20161214.zip
        URL_HASH SHA1=454d619fca0f4bf68fb5b346a05e905e1054ea01
    )
ENDIF()

ExternalProject_Add(
    asio

    ${ASIO_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/asio
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
)

ExternalProject_Get_Property(asio INSTALL_DIR)

SET_TARGET_PROPERTIES(asio PROPERTIES FOLDER "Dependencies")

SET(ASIO_INCLUDE_DIRS "${INSTALL_DIR}/src/asio/asio/include")

FILE(MAKE_DIRECTORY "${ASIO_INCLUDE_DIRS}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/tinyxml2.zip")
    SET(TINYXML2_URL
        URL "${CMAKE_SOURCE_DIR}/deps/tinyxml2.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(TINYXML2_URL
        GIT_REPOSITORY https://github.com/comphack/tinyxml2.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(TINYXML2_URL
        URL https://github.com/comphack/tinyxml2/archive/comp_hack-20180424.zip
        URL_HASH SHA1=c0825970d84f2418ff8704624b020e65d02bc5f3
    )
ENDIF()

ExternalProject_Add(
    tinyxml2-ex

    ${TINYXML2_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/tinyxml2
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DBUILD_SHARED_LIBS=OFF "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tinyxml2${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tinyxml2d${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tinyxml2_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(tinyxml2-ex INSTALL_DIR)

SET_TARGET_PROPERTIES(tinyxml2-ex PROPERTIES FOLDER "Dependencies")

SET(TINYXML2_INCLUDE_DIRS "${INSTALL_DIR}/include")

FILE(MAKE_DIRECTORY "${TINYXML2_INCLUDE_DIRS}")

ADD_LIBRARY(tinyxml2 STATIC IMPORTED)
ADD_DEPENDENCIES(tinyxml2 tinyxml2-ex)

IF(WIN32)
    SET_TARGET_PROPERTIES(tinyxml2 PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tinyxml2${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tinyxml2_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tinyxml2d${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(tinyxml2 PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}tinyxml2${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(tinyxml2 PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${TINYXML2_INCLUDE_DIRS}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/googletest.zip")
    SET(GOOGLETEST_URL
        URL "${CMAKE_SOURCE_DIR}/deps/googletest.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(GOOGLETEST_URL
        GIT_REPOSITORY https://github.com/comphack/googletest.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(GOOGLETEST_URL
        URL https://github.com/comphack/googletest/archive/comp_hack-20180425.zip
        URL_HASH SHA1=40b8e97ef07d300539bd2a5d6b1c1cfcd92deb7b
    )
ENDIF()

ExternalProject_Add(
    googletest

    ${GOOGLETEST_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/googletest
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_main${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtestd${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmockd${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_maind${CMAKE_STATIC_LIBRARY_SUFFIX}

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_main_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(googletest INSTALL_DIR)

SET_TARGET_PROPERTIES(googletest PROPERTIES FOLDER "Dependencies")

SET(GTEST_INCLUDE_DIRS "${INSTALL_DIR}/include")

FILE(MAKE_DIRECTORY "${GTEST_INCLUDE_DIRS}")

ADD_LIBRARY(gtest STATIC IMPORTED)
ADD_DEPENDENCIES(gtest googletest)

IF(WIN32)
    SET_TARGET_PROPERTIES(gtest PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtestd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(gtest PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(gtest PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${GTEST_INCLUDE_DIRS}")

ADD_LIBRARY(gmock STATIC IMPORTED)
ADD_DEPENDENCIES(gmock googletest)

IF(WIN32)
    SET_TARGET_PROPERTIES(gmock PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmockd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(gmock PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(gmock PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${GTEST_INCLUDE_DIRS}")

ADD_LIBRARY(gmock_main STATIC IMPORTED)
ADD_DEPENDENCIES(gmock_main googletest)

IF(WIN32)
    SET_TARGET_PROPERTIES(gmock_main PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_main${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_main_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_maind${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(gmock_main PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock_main${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(gmock_main PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${GTEST_INCLUDE_DIRS}")

SET(GMOCK_DIR "${INSTALL_DIR}")

IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/JsonBox.zip")
    SET(JSONBOX_URL
        URL "${CMAKE_SOURCE_DIR}/deps/JsonBox.zip"
    )
ELSEIF(GIT_DEPENDENCIES)
    SET(JSONBOX_URL
        GIT_REPOSITORY https://github.com/comphack/JsonBox.git
        GIT_TAG comp_hack
    )
ELSE()
    SET(JSONBOX_URL
        URL https://github.com/comphack/JsonBox/archive/comp_hack-20180424.zip
        URL_HASH SHA1=60fce942f5910a6da8db27d4dcb894ea28adea57
    )
ENDIF()

ExternalProject_Add(
    jsonbox-ex

    ${JSONBOX_URL}

    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/JsonBox
    CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DBUILD_SHARED_LIBS=OFF "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

    # Dump output to a log instead of the screen.
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON

    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBoxd${CMAKE_STATIC_LIBRARY_SUFFIX}
    BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(jsonbox-ex INSTALL_DIR)

SET_TARGET_PROPERTIES(jsonbox-ex PROPERTIES FOLDER "Dependencies")

SET(JSONBOX_INCLUDE_DIRS "${INSTALL_DIR}/include")

FILE(MAKE_DIRECTORY "${JSONBOX_INCLUDE_DIRS}")

ADD_LIBRARY(jsonbox STATIC IMPORTED)
ADD_DEPENDENCIES(jsonbox jsonbox-ex)

IF(WIN32)
    SET_TARGET_PROPERTIES(jsonbox PROPERTIES
        IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
        IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBoxd${CMAKE_STATIC_LIBRARY_SUFFIX}")
ELSE()
    SET_TARGET_PROPERTIES(jsonbox PROPERTIES IMPORTED_LOCATION
        "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox${CMAKE_STATIC_LIBRARY_SUFFIX}")
ENDIF()

SET_TARGET_PROPERTIES(jsonbox PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${JSONBOX_INCLUDE_DIRS}")
