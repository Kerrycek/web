<?php
require_once dirname(__FILE__).'/../../../lib/form.php';

if (!$f)
	$f = new RegistrationForm('cs');
?>
<label for="name">Přihlašovací jméno</label>
<div class="row">
	<div class="col-xs-12 form-group">
		<?php $f->input('login'); ?>
	</div>
</div>

<label for="first_name">Osobní údaje</label>
<div class="row form-group">
	<div class="col-xs-12">
		<?php $f->input('name'); ?>
	</div>
</div>

<div class="row">
	<div class="col-xs-6 form-group">
		<?php $f->input('email'); ?>
	</div>

	<div class="col-xs-6">
		<?php
			$y = date('Y');
			$f->input('birth', 'number', array('min' => $y - 100, 'max' => $y - 6));
		?>
	</div>
</div>

<label for="name">Adresa</label>
<div class="row">
	<div class="col-xs-6 form-group">
		<?php $f->input('address') ?>
	</div>

	<div class="col-xs-6">
		<?php $f->input('city'); ?>
	</div>
</div>

<div class="row">
	<div class="col-xs-6 form-group">
		<?php $f->input('zip'); ?>
	</div>

	<div class="col-xs-6">
		<?php $f->input('country'); ?>
	</div>
</div>

<?php include dirname(__FILE__).'/../spolecne.php'; ?>
