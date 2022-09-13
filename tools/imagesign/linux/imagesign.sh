#/bin/sh


#version
version=v1.0

#image tag
image_tee=tee
image_tf=tf
image_uboot=uboot

# image name 
image_tee_name=tee.bin
image_tf_name=trust_firmware.bin
image_uboot_name=u-boot-with-spl.bin

# signed image prefix
prefix_signed_ia_nor=signed_ia_nor_
prefix_signed_ia_enc=signed_ia_enc_
prefix_signed_sm_nor=signed_sm_nor_
prefix_signed_sm_enc=signed_sm_enc_
prefix_signed_pubkey=signed_pubkey_
prefix_signed_img=signed_image_
# image path
image_tee_path=tee
image_tf_path=tf
image_uboot_path=uboot

# image relocated address
image_tee_addr=0x1c000000
image_tf_addr=0x0
image_uboot_addr=0xFFE0000800

# image version
image_ver_h=0
image_ver_l=0
image_ver=0

# algorithm type
algo_ia=ia
algo_sm=sm
 
# image encryption attribution
attr_enc=enc
attr_nor=nor

# sign tool path
signtool=./tool/product

# sign certification
thead_root_public_cert=pubkeyA.pem
thead_root_private_cert=privatekeyA.pem
thead_b1_public_cert=pubkeyB.pem
thead_b1_private_cert=privatekeyB.pem
client_public_cert=pubkeyB.pem
client_private_cert=privatekeyB.pem

function help(){
	echo ""
	echo "imagesign.sh utility version ${version}"
	echo "The utility is designed for aim to help user generate new image file"
	echo "with signature with desired sign scheme."
	echo ""
	echo "Usage:"
	echo "imagesign.sh [ia/sm] [enc/nor] [tf/tee/uboot] [ver]"
	echo "signed algorithms"
	echo "	ia - international algorithm"
	echo "	sm - china algorithms"
	echo "secure attribution"
	echo "	enc	- signed image with encryption"
	echo "	nor	- signed image without encryption"
	echo "image file type"
	echo "	tf   - trust_firmware binary image"
	echo "	tee  - tee binary image"
	echo "	boot - uboot binary image"
	echo "version"
	echo "	ver - image version (x.y), eg 1.1, 2.1 "
	echo ""
	echo ""
}

# The function convert X.Y string to integer used in sign tool
# $1 - X
# $2 - Y
function get_image_version(){
	let image_ver=$1*256+$2
	return ;
}

# parameters definion
# $1 - secure attribution
# $2 - image file name
# $3 - image version
function image_sign_ia(){

	echo "sign tool path: ${signtool}"

    local image_version=v$3_

	if [ $2 == $image_uboot ]; then
		if [ $1 == $attr_nor ]; then
			local infile_path=${image_uboot_path}/${image_uboot_name}
			local outfile_path=${image_uboot_path}/${prefix_signed_ia_nor}${image_version}${image_uboot_name}
			local outfile_h_path=${image_uboot_path}/${prefix_signed_pubkey}${image_uboot_name}
			local outfile_i_path=${image_uboot_path}/${prefix_signed_img}${image_version}${image_uboot_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_uboot_addr"

			#Generate public key img
			$signtool sigx keystore/${thead_b1_public_cert} \
			-pvk keystore/${thead_root_private_cert} \
			-pubk keystore/${thead_root_public_cert} -ss RSA2048 -ds SHA256 \
			-npubk keystore/${thead_b1_public_cert} -nss RSA2048 -nds SHA256 \
			-o ${outfile_h_path}

			#Generate BL1
			$signtool sigx ${infile_path} \
			-pvk keystore/${thead_b1_private_cert} -ss RSA2048  -ds SHA256 \
			-npubk keystore/${client_public_cert} -nss RSA2048  -nds SHA256 \
			-iv $image_ver \
			-ra $image_uboot_addr \
			-o ${outfile_i_path}

			#Combine the above two img 
			cat ${outfile_h_path} ${outfile_i_path} > ${outfile_path}

		elif [ $1 == $attr_enc ]; then
			local infile_path=${image_uboot_path}/${image_uboot_name}
			local outfile_path=${image_uboot_path}/${prefix_signed_ia_enc}${image_version}${image_uboot_name}
			local outfile_h_path=${image_uboot_path}/${prefix_signed_pubkey}${image_uboot_name}
			local outfile_i_path=${image_uboot_path}/${prefix_signed_img}${image_version}${image_uboot_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_uboot_addr"

			#Generate public key img
			$signtool sigx keystore/${thead_b1_public_cert} \
			-pvk keystore/${thead_root_private_cert} \
			-pubk keystore/${thead_root_public_cert} -ss RSA2048 -ds SHA256 \
			-npubk keystore/${thead_b1_public_cert} -nss RSA2048 -nds SHA256 \
			-o ${outfile_h_path}

			#Generate BL1
			$signtool sigx ${infile_path} \
			-pvk keystore/${thead_b1_private_cert} -ss RSA2048  -ds SHA256 \
			-npubk keystore/${client_public_cert} -nss RSA2048  -nds SHA256 \
			-ent AES_256_CBC -enk keystore/aes_256_cbc.key \
			-iv $image_ver \
			-ra $image_uboot_addr \
			-o ${outfile_i_path}

			#Combine the above two img 
			cat ${outfile_h_path} ${outfile_i_path} > ${outfile_path}

		else
			echo "Error in operation !"
			exit
		fi


	elif [ $2 == $image_tee ]; then
		if [ $1 == $attr_nor ]; then
			local infile_path=${image_tee_path}/${image_tee_name}
			local outfile_path=${image_tee_path}/${prefix_signed_ia_nor}${image_version}${image_tee_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_tee_addr"

			$signtool sigx ${infile_path} \
			-pvk keystore/${client_private_cert} -ss RSA2048  -ds SHA256 \
			-npubk keystore/${client_public_cert} -nss RSA2048  -nds SHA256 \
			-iv $image_ver \
			-ra $image_tee_addr \
			-o ${outfile_path}

		elif [ $1 == $attr_enc ]; then
			local infile_path=${image_tee_path}/${image_tee_name}
			local outfile_path=${image_tee_path}/${prefix_signed_ia_enc}${image_version}${image_tee_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_tee_addr"

			$signtool sigx ${infile_path} \
			-pvk keystore/${client_private_cert} -ss RSA2048  -ds SHA256 \
			-npubk keystore/${client_public_cert} -nss RSA2048  -nds SHA256 \
			-ent AES_256_CBC -enk keystore/aes_256_cbc.key \
			-iv $image_ver \
			-ra $image_tee_addr \
			-o ${outfile_path}
		
		else
			echo "Error in operation !"
			exit
		fi
	elif [ $2 == $image_tf ]; then
		if [ $1 == $attr_nor ]; then
			local infile_path=${image_tf_path}/${image_tf_name}
			local outfile_path=${image_tf_path}/${prefix_signed_ia_nor}${image_version}${image_tf_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_tf_addr"

			$signtool sigx ${infile_path} \
			-pvk keystore/${client_private_cert} -ss RSA2048  -ds SHA256 \
			-npubk keystore/${client_public_cert} -nss RSA2048  -nds SHA256 \
			-iv $image_ver \
			-ra $image_tf_addr \
			-o ${outfile_path}

		elif [ $1 == $attr_enc ]; then
			local infile_path=${image_tf_path}/${image_tf_name}
			local outfile_path=${image_tf_path}/${prefix_signed_ia_enc}${image_version}${image_tf_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_tf_addr"

			$signtool sigx ${infile_path} \
			-pvk keystore/${client_private_cert} -ss RSA2048  -ds SHA256 \
			-npubk keystore/${client_public_cert} -nss RSA2048  -nds SHA256 \
			-ent AES_256_CBC -enk keystore/aes_256_cbc.key \
			-iv $image_ver \
			-ra $image_tf_addr \
			-o ${outfile_path}
		
		else
			echo "Error in operation !"
			exit
		fi
	else
		echo "Panic ..."
	fi

	return
}

# parameters definion
# $1 - secure attribution
# $2 - image file name
# $3 - image version
function image_sign_sm(){

	echo "sign tool path: ${signtool}"
    
    local image_version=v$3_

	if [ $2 == $image_uboot ]; then
		if [ $1 == $attr_nor ]; then
			local infile_path=${image_uboot_path}/${image_uboot_name}
			local outfile_path=${image_uboot_path}/${prefix_signed_sm_nor}${image_version}${image_uboot_name}
			local outfile_h_path=${image_uboot_path}/${prefix_signed_pubkey}${image_uboot_name}
			local outfile_i_path=${image_uboot_path}/${prefix_signed_img}${image_version}${image_uboot_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_uboot_addr"

			#Generate public key img
			$signtool sigx keystore_sm/${thead_b1_public_cert} \
			-pvk keystore_sm/${thead_root_private_cert} \
			-pubk keystore_sm/${thead_root_public_cert} -ss SM2 -ds SM3 \
			-npubk keystore_sm/${thead_b1_public_cert} -nss SM2 -nds SM3 \
			-o ${outfile_h_path}

			#Generate BL1
			$signtool sigx ${infile_path} \
			-pvk keystore_sm/${thead_b1_private_cert} -ss SM2  -ds SM3 \
			-npubk keystore_sm/${client_public_cert} -nss SM2  -nds SM3 \
			-iv $image_ver \
			-ra $image_uboot_addr \
			-o ${outfile_i_path}

			#Combine the above two img 
			cat ${outfile_h_path} ${outfile_i_path} > ${outfile_path}

		elif [ $1 == $attr_enc ]; then
			local infile_path=${image_uboot_path}/${image_uboot_name}
			local outfile_path=${image_uboot_path}/${prefix_signed_sm_enc}${image_version}${image_uboot_name}
			local outfile_h_path=${image_uboot_path}/${prefix_signed_pubkey}${image_uboot_name}
			local outfile_i_path=${image_uboot_path}/${prefix_signed_img}${image_version}${image_uboot_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_uboot_addr"

			#Generate public key img
			$signtool sigx keystore_sm/${thead_b1_public_cert} \
			-pvk keystore_sm/${thead_root_private_cert} \
			-pubk keystore_sm/${thead_root_public_cert} -ss SM2 -ds SM3 \
			-npubk keystore_sm/${thead_b1_public_cert} -nss SM2 -nds SM3 \
			-o ${outfile_h_path}

			#Generate BL1
			$signtool sigx ${infile_path} \
			-pvk keystore_sm/${thead_b1_private_cert} -ss SM2  -ds SM3 \
			-npubk keystore_sm/${client_public_cert} -nss SM2  -nds SM3 \
			-ent SM4_CBC -enk keystore_sm/sm4.key \
			-iv $image_ver \
			-ra $image_uboot_addr \
			-o ${outfile_i_path}

			#Combine the above two img 
			cat ${outfile_h_path} ${outfile_i_path} > ${outfile_path}

		else
			echo "Error in operation !"
			exit
		fi

	elif [ $2 == $image_tee ]; then
		if [ $1 == $attr_nor ]; then
			local infile_path=${image_tee_path}/${image_tee_name}
			local outfile_path=${image_tee_path}/${prefix_signed_sm_nor}${image_version}${image_tee_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_tee_addr"

			$signtool sigx ${infile_path} \
			-pvk keystore_sm/${client_private_cert} -ss SM2  -ds SM3 \
			-npubk keystore_sm/${client_public_cert} -nss SM2  -nds SM3 \
			-iv $image_ver \
			-ra $image_tee_addr \
			-o ${outfile_path}

		elif [ $1 == $attr_enc ]; then
			local infile_path=${image_tee_path}/${image_tee_name}
			local outfile_path=${image_tee_path}/${prefix_signed_sm_enc}${image_version}${image_tee_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_tee_addr"

			$signtool sigx ${infile_path} \
			-pvk keystore_sm/${client_private_cert} -ss SM2  -ds SM3 \
			-npubk keystore_sm/${client_public_cert} -nss SM2  -nds SM3 \
			-ent SM4_CBC -enk keystore_sm/sm4.key \
			-iv $image_ver \
			-ra $image_tee_addr \
			-o ${outfile_path}

		
		else
			echo "Error in operation !"
			exit
		fi
	elif [ $2 == $image_tf ]; then
		if [ $1 == $attr_nor ]; then
			local infile_path=${image_tf_path}/${image_tf_name}
			local outfile_path=${image_tf_path}/${prefix_signed_sm_nor}${image_version}${image_tf_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_tf_addr"

			$signtool sigx ${infile_path} \
			-pvk keystore_sm/${client_private_cert} -ss SM2  -ds SM3 \
			-npubk keystore_sm/${client_public_cert} -nss SM2  -nds SM3 \
			-iv $image_ver \
			-ra $image_tf_addr \
			-o ${outfile_path}

		elif [ $1 == $attr_enc ]; then
			local infile_path=${image_tf_path}/${image_tf_name}
			local outfile_path=${image_tf_path}/${prefix_signed_sm_enc}${image_version}${image_tf_name}
			echo "Original file: ${infile_path}"
			echo "Signed file: ${outfile_path}"
			echo "Image Version: $image_ver"
			echo "Relocate Addr: $image_tf_addr"

			$signtool sigx ${infile_path} \
			-pvk keystore_sm/${client_private_cert} -ss SM2  -ds SM3 \
			-npubk keystore_sm/${client_public_cert} -nss SM2  -nds SM3 \
			-ent SM4_CBC -enk keystore_sm/sm4.key \
			-iv $image_ver \
			-ra $image_tf_addr \
			-o ${outfile_path}
		
		else
			echo "Error in operation !"
			exit
		fi
	else
		echo "Panic ..."
	fi
	return
}

function image_sign(){
	
	echo "Enter into image sign process ..."

	if [ $1 == $algo_ia ]; then
		echo "Start $3 Image ($4) signed with international algorithms with secure attr ($2)"
		image_sign_ia $2 $3 $4

	elif [ $1 == $algo_sm ]; then
		echo "Start $3 Image ($4) signed with china_gov algorithms with secure attr ($2)"
		image_sign_sm $2 $3 $4
	fi

	echo "Exit from image sign process ..."

	return 
}

function imagesign_main(){

	# check user parameters count
	if (( $# < 4)); then
		help
		exit
	fi

	# check algorithm and secure
	if [ $1 != $algo_ia ] && [ $1 != $algo_sm ]; then
		echo "Unsupported algorithms."
		exit
	fi

	# check image attrubtion
	if [ $2 != $attr_nor ] && [ $2 != $attr_enc ]; then
		echo "Unsupported secure attribtion."
		exit
	fi

	# check image file
	if [ $3 != $image_uboot ] && [ $3 != $image_tee ] && [ $3 != $image_tf ]; then
		echo "Unsupported image file."
		exit
	fi

	# check version
	# the version string must be X.Y format. we will convert to digital format for use case 
	# 
	image_ver_h=`echo $4 | awk -F . '{print $1}'`
	image_ver_l=`echo $4 | awk -F . '{print $2}'`
	#echo "image version X.Y: ${image_ver_h}.${image_ver_l}"
	if [ $3 == $image_uboot ]; then
        let image_ver_h=${image_ver_h}-1
		get_image_version ${image_ver_l} ${image_ver_h};
	else
		get_image_version ${image_ver_h} ${image_ver_l};
	fi

	# dump all parameters from upper layer
	echo "Dump all parameters from user input."
	echo "------------------------------------"
	echo "Signed algorithem: $1"
	echo "Secure attribution: $2"
	echo "Image file: $3"
	echo "Image version: $4"
	echo "------------------------------------"
	# Call image sign function here
	image_sign $1 $2 $3 $4

}

# Parameters definition
# $1 - ia
imagesign_main $1 $2 $3 $4
